extends "res://common/game/Game.gd"

var unreadyPlayers := {}
var AttackEffect = preload("res://common/game/projectiles/AttackEffect.gd")

func _init():
	self.connect("spawn_flag", self, "handle_spawn_flag")

func _ready():
	self.connect("spawn_projectile", self, "set_projectile_connection")
	$Level.connect("flag_picked_up", self, "flag_picked_up")
	$Level.connect("spawn_resource", self, "spawn_resource")
	$Level.connect("split_resources", self, "split_resources")

	ClientNetwork.connect("all_disconnected", self, "end_game")

	for playerId in GameData.players:
		unreadyPlayers[playerId] = playerId
	for playerId in self.players:
		var player = self.players[playerId]
		player.connect("take_damage", self, "damage_taken")
		player.connect("weapon_auto_attack", self, "weapon_auto_attack", [ player ])
		player.connect("flag_captured", self, "player_captured_flag", [ player ])
		player.connect("pickup_weapon", self, "player_picked_up_weapon", [ player ])

remote func on_client_ready(playerId):
	print("client ready: %s" % playerId)
	unreadyPlayers.erase(playerId)
	print("Still waiting on %d players" % unreadyPlayers.size())
	
	# All clients are done, unpause the game
	if unreadyPlayers.empty():
		print("Starting the game")
		rpc("on_pre_configure_complete")
		# start countdown timer
		on_pre_configure_complete()

func on_pre_configure_complete():
	# spawn pistols for all players
	for player in players.values():
		var weapon = server_spawn_weapon("pistol")
		player_picked_up_weapon(weapon, player)
		var weapon2 = server_spawn_weapon("baguette")
		player_picked_up_weapon(weapon2, player)
	.on_pre_configure_complete()

func remove_player(playerId: int):
	# If all players are gone, return to lobby
	if GameData.players.empty():
		print("All players disconnected, returning to lobby")
		get_tree().change_scene("res://server/lobby/ServerLobby.tscn")
	else:
		print("Players remaining: %d" % GameData.players.size())

func _physics_process(delta):
	var arr = []
	for playerId in self.players:
		var player = self.players[playerId]
		arr.append({position = player.position, id = player.id, lookDirection = player.server_direction})
	rpc_unreliable("update_player_position", arr)

func get_player_scene():
	return load("res://server/game/ServerPlayer.tscn")

func handle_spawn_flag(flag):
	print("handling spawn flag")
	flag.connect("flag_picked_up", self, "flag_picked_up")

func flag_picked_up(flag : Node2D, player : Node2D):
	print("telling clients, flag was picked up")
	rpc("on_flag_picked_up", flag.teamIndex, player.id)
	print("ServerGame: Flag ID: " + str(flag.teamIndex) + " PlayerId: " + str(player.id))

func damage_taken(playerId: int, newHealth: int):
	rpc("on_take_damage", playerId, newHealth)

func weapon_auto_attack(player):
	var playerId = player.id
	var weapon = player.get_weapon()
	rpc("on_weapon_attack", weapon.id)
	var attackEffects = weapon.on_attack_effect()

	for x in attackEffects:
		match x.attackEffectType:
			AttackEffect.attackEffectTypes.SPAWN_PROJECTILES:
				weapon_attack_spawn_projectile(x)
			AttackEffect.attackEffectTypes.MELEE_ATTACK:
				weapon_attack_melee(x)
	rpc_id(playerId, "on_ammo_changed", weapon.ammo)

# remote func single_attacked():
# 	var playerId = get_tree().get_rpc_sender_id()
# 	print("Got gun_fired from: " + str(playerId))
# 	var player = get_player(playerId)
# 	var weapon = player.get_weapon()
# 	if weapon == null:
# 		print("no weapon")
# 		return
# 	var position = player.get_projectile_spawn_position()
# 	var direction = player.get_direction()
# 	rpc("on_spawn_projectile", position, direction, weapon.projectile, UUID.v4())
# 	rpc_id(playerId, "on_ammo_changed", weapon.ammo)

func weapon_attack_spawn_projectile(attackEffect : AttackEffect):
	on_spawn_projectile(attackEffect.data["projectile_spawn_position"], attackEffect.direction, attackEffect.data["projectile_type"], attackEffect.data["id"], attackEffect.knockbackFactor, attackEffect.damage)
	rpc("on_spawn_projectile", attackEffect.data["projectile_spawn_position"], attackEffect.direction, attackEffect.data["projectile_type"], attackEffect.data["id"], attackEffect.knockbackFactor, attackEffect.damage)

func weapon_attack_melee(attackEffect : AttackEffect):
	var player = attackEffect.data["player"]
	var tag = player.get_meta("tag")
	if tag == "player":
		player.take_damage(attackEffect.damage)
		player.knockback(attackEffect.knockbackFactor, attackEffect.direction)

remote func auto_attacked(start):
	var playerId = get_tree().get_rpc_sender_id()
	var player = get_player(playerId)
	player.set_attacking(start)

func respawn_player(playerId: int):
	var player = get_player(playerId)

	if !is_flag_taken(player.teamIndex):
		rpc("on_respawn_player", playerId)
		print("respawning player with playerId: " + str(playerId))

func get_alive_teams():
	var aliveTeams = []
	for team in GameData.teams:
		if !is_flag_taken(team.index): # There is a flag!!!
			aliveTeams.append(team.index)
		else:
			for player in team.players:
				var gamePlayer = get_player(player)
				if !gamePlayer.dead:
					aliveTeams.append(team.index)
					break
	print(aliveTeams)
	return aliveTeams

func set_projectile_connection(projectile: Node):
	projectile.connect("hit", self, "projectile_hit")
	projectile.connect("age_timeout", self, "despawn_projectile")

func projectile_hit(projectile: Node2D, collider: Node2D):
	var tag = collider.get_meta("tag")
	if tag == "player":
		collider.take_damage(projectile.damage)
		collider.knockback(projectile.knockbackFactor, projectile.direction)
	.on_projectile_hit(projectile.id)
	rpc("on_projectile_hit", projectile.id)

func resource_amount_changed(player: Node2D):
	rpc_id(player.id, "resource_amount_changed", player.resources)

func player_captured_flag(player : Node2D):
	print("got flag captured from player " + str(player.id))
	on_flag_captured(player.id)
	rpc("on_flag_captured", player.id)
	#rpc_id(player.id, "resource_amount_changed", player.resources) # this is redundant, can be done on client
	check_game_is_ending()

func load_lobby():
	get_tree().change_scene("res://server/lobby/ServerLobby.tscn")

func spawn_resource(resourceSpawner: Node2D):
	# rpc call that the resource spawner has spawned a new resource
	rpc("resource_spawned", resourceSpawner.id)

func split_resources(resourceSpawner: Node2D):
	# rpc id call to the player that they picked up x amount of y resource
	var players = resourceSpawner.get_players_inside()
	# update server player
	resourceSpawner.update_player_resources()
	for player in players:
		# tell the client the player was updated
		resource_amount_changed(player)
	# rpc call that the resource spawner is now empty
	# call this after telling the players that they picked up the resources
	rpc("resources_picked_up", resourceSpawner.id)

func server_spawn_weapon(weaponType : String, position : Vector2 = Vector2.ZERO, id : String = UUID.v4()):
	print("server spawn weapon called")
	rpc("on_spawn_weapon", weaponType, id, position)
	var weapon = spawn_weapon(weaponType, id, position)
	weapon.connect("start_reload", self, "on_start_reload", [weapon])
	return weapon

func on_start_reload(weapon : Node2D):
	rpc("on_start_reload", weapon.id)

func update_weapon_on_player(weaponInstance: Node2D, player):
	.update_weapon_on_player(weaponInstance, player)
	rpc("on_update_weapon_on_player", weaponInstance.id, player.id)

remote func debug_command(command : String, args : Array = []):
	if GameData.debug == true:
		var playerId = get_tree().get_rpc_sender_id()
		var player = get_player(playerId)
		print("debug_command was called")
		if has_node("DebugScript"):
			$DebugScript.command(command, player, args)

func player_picked_up_weapon(weapon, player):
	player.on_pickup_weapon(weapon)
	var weaponData = {
		ammo = weapon.ammo,
		reloads = weapon.reloads,
	}
	rpc("on_player_pickup_weapon", player.id, weapon.id, weaponData)

func despawn_projectile(projectile : Node2D):
	.on_projectile_despawn(projectile.id)
	rpc("on_projectile_despawn", projectile.id)

func spawn_player(playerId, teamNode, spawnNode):
	var playerNode = .spawn_player(playerId, teamNode, spawnNode)
	playerNode.connect("player_dead", self, "player_dies")
	return playerNode

func player_dies(playerId: int):
	on_player_dead(playerId)
	rpc("on_player_dead", playerId)
	check_game_is_ending()

func check_game_is_ending():
	var aliveTeams = get_alive_teams()
	if aliveTeams.size() < 2:
		rpc("end_game")
		end_game()

remote func purchase_item(itemId):
	var playerId = get_tree().get_rpc_sender_id()
	var player = get_player(playerId)
	# find item
	var itemData = GameData.gameShopData.itemsById[itemId]
	# check and deduct resources
	var cost = itemData.cost
	if !check_player_item_cost(player, cost):
		return
	# deduct cost
	on_deduct_cost(player, cost)
	rpc_id(playerId, "on_deduct_cost", playerId, cost)
	# Spawn item
	var itemTypes = GameData.gameShopData.ItemTypes
	match itemData.itemType:
		itemTypes.WEAPON:
			# Spawn weapon
			var weapon = server_spawn_weapon(itemData.res)
			update_weapon_on_player(weapon, player)
