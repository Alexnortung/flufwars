extends Node2D

signal spawn_flag
signal spawn_projectile

var gameStarted : bool = false
var gameStartCountdownTime = 3
var levelNode : Node2D
var players = {}
var projectiles = {}
# Entities are other Nodes with ids
var entities = {}
var rng = RandomNumberGenerator.new()
const projectileTypes = {
	base_projectile = preload("res://common/game/projectiles/BaseProjectile.tscn"), # 0
}

const weaponTypes = {
	# BaseWeapon is abstract so we should not use it here
	pistol = preload("res://common/game/weapons/Pistol.tscn"),
	baguette = preload("res://common/game/weapons/LeBaguette.tscn"),
	ak = preload("res://common/game/weapons/AK.tscn"),
}

func _ready():
	$Countdown.connect("countdown_finished", self, "on_start_game_countdown_finish")
	print("Entering game")
	get_tree().paused = true
	
	ClientNetwork.connect("remove_player", self, "remove_game_player")
	
	pre_configure()



func remove_game_player(playerId: int):
	get_player(playerId).queue_free()
	players.erase(playerId)

func pre_configure():
	var order := 0
	var sortedPlayers = []

	loadLevel()

	for playerId in GameData.players:
		sortedPlayers.push_back(playerId)
	
	sortedPlayers.sort()
	# var i = 0

	var teamNodes = $Level.get_node("Teams").get_children()
	var teamIndex = 0
	for teamData in GameData.teams:
		var teamNode = teamNodes[teamIndex]
		var playerSpawnNodes = teamNode.get_node("PlayerSpawns").get_children()
		var i = 0
		for playerId in teamData.players:
			var playerData = teamData.players[playerId]
			var spawnNode = playerSpawnNodes[i]
			# create player node
			var playerNode = spawn_player(playerData.id, teamNode, spawnNode)
			i += 1
			print("created player: id: " + str(playerNode.id) + " teamIndex: " + str(playerNode.teamIndex))
		teamIndex += 1
	
	if not get_tree().is_network_server():
		# Report that this client is done
		rpc_id(ServerNetwork.SERVER_ID, "on_client_ready", get_tree().get_network_unique_id())

func loadLevel():
	print("SCENE PATH")
	print(GameData.mapInfo.levelScenePath)
	var levelScene = load(GameData.mapInfo.levelScenePath)
	levelNode = levelScene.instance()
	levelNode.set_name("Level")
	add_child(levelNode)
	move_child(levelNode, 0)

# virtual lobby
func load_lobby():
	pass
	

func spawn_player(playerId, teamNode, spawnNode):
	var teamIndex = teamNode.teamIndex
	print("Creating player game object")
	
	var player = GameData.players[playerId]
	var playerName = player[GameData.PLAYER_NAME]
	
	var scene = get_player_scene() 
	
	var playerNode = scene.instance()
	playerNode.init(playerId, teamIndex, spawnNode)
	playerNode.set_network_master(playerId)
	playerNode.set_name(str(playerId))
	
	playerNode.position = spawnNode.position

	add_camera_to_player(playerId, playerNode)
	
	playerNode.get_node("NameLabel").text = playerName
	playerNode.get_node("PlayerAnim").set_sprite_frames(GameData.mapInfo.colorDic[teamIndex].playerAnim)
	self.get_node("Players").add_child(playerNode)
	spawnNode.playerNode = playerNode
	players[playerId] = playerNode
	playerNode.get_node("RespawnTimer").connect("timeout", self, "respawn_player", [playerId])
	return playerNode

# virtual function
func add_camera_to_player(playerId: int, playerNode: Node2D):
	pass

#virtual function
func get_player_scene():
	pass

func get_player(playerId : int) -> Node2D:
	for _playerId in players:
		var player = players[_playerId]
		if playerId == player.id:
			return player
	return null

func get_flag(teamIndex):
	return $Level.get_flag(teamIndex)

func is_flag_taken(teamIndex):
	var flag = get_flag(teamIndex)
	if flag == null:
		return true
	if flag.isTaken:
		return true
	return false

func on_pre_configure_complete():
	print("All clients are configured. Starting the game.")
	start_game_countdown()

remotesync func on_flag_picked_up(teamIndex : int, playerId : int):
	var flag = get_flag(teamIndex)
	var player = get_player(playerId)
	flag.picked_up(flag, player)
	print("Game remote: picking up the flag. Teamindex: " + str(teamIndex) + " playerId: " + str(playerId))

remotesync func on_take_damage(playerId: int, newHealth: int):
	print("player takes damage")
	get_player(playerId).update_health(newHealth)

func on_spawn_projectile(position: Vector2, direction: Vector2, projectileType: String, projectileId: String, knockbackFactor : float, damage : int):
	var projectileLoad = projectileTypes[projectileType]
	var projectile = projectileLoad.instance()
	projectile.init(position, direction, knockbackFactor, damage, projectileId)
	add_child(projectile)
	projectiles[projectileId] = projectile
	emit_signal("spawn_projectile", projectile)
	return projectile

remotesync func on_respawn_player(playerId: int):
	var player = get_player(playerId)
	player.position = player.playerSpawn.position
	player.health = player.initHealth
	player.kill_player(false)

func player_dead(player: Node2D):
	player.kill_player(true)

func respawn_player(playerId: int):
	pass

func on_projectile_hit(projectileId : String):
	on_projectile_despawn(projectileId)

func on_projectile_despawn(projectileId : String):
	projectiles[projectileId].queue_free()
	projectiles.erase(projectileId)

func on_flag_captured(playerId):
	get_player(playerId).flag_captured()

remotesync func resources_picked_up(resourceSpawnerId: String):
	$Level.get_resource_spawner(resourceSpawnerId).on_pickup()

remotesync func resource_spawned(resourceSpawnerId: String):
	$Level.get_resource_spawner(resourceSpawnerId).on_spawn_resource()


func end_game():
	load_lobby()

func spawn_weapon(weaponType : String, id : String, position : Vector2):
	var weapon = weaponTypes[weaponType].instance()
	weapon.init(id, position)
	entities[id] = weapon
	add_child(weapon)
	return weapon

func start_game_countdown():
	print("countdown started")
	$Countdown.start(gameStartCountdownTime)

func on_start_game_countdown_finish():
	print("countdown finisehd")
	get_tree().paused = false

# Checks that the player has enough resources to purchase item
func check_player_item_cost(player, cost : Array) -> bool:
	for i in range(len(cost)):
		if player.resources[i] < cost[i]:
			return false
	return true

func update_weapon_on_player(weaponInstance : Node2D, player):
	# add the weapon to the player
	player.on_pickup_weapon(weaponInstance)

func on_deduct_cost(player: Node2D, cost: Array):
	for i in range(len(cost)):
		player.resources[i] -= cost[i]

func spawn_resource_drop(position : Vector2, type : int, amount: int, id : String):
	var scene = get_resource_drop_scene()
	var resourceDrop = scene.instance()
	resourceDrop.init(position, type, amount, id)
	call_deferred("add_child", resourceDrop)
	entities[id] = resourceDrop
	return resourceDrop

func get_resource_drop_scene():
	var resourceDropScene = load("res://common/game/ResourceDrops/ResourceDrop.tscn")
	return resourceDropScene

func resource_drop_pickup(resourceDrop, player):
	entities.erase(resourceDrop.id)
	resourceDrop.queue_free()
