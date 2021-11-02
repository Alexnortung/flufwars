extends "res://common/game/Game.gd"

var ResourceSplash = preload("res://client/game/Gameplay/ResourceSplash.tscn")

func _ready():
	var clientPlayer = get_client_player()
	$Countdown.connect("countdown_updated", get_ui(), "countdown_updated")
	$Countdown.connect("countdown_finished", get_ui(), "countdown_finished")
	clientPlayer.connect("single_attack", self, "single_attack")
	clientPlayer.connect("auto_attack", self, "auto_attack")
	$DebugUI.connect("debug_command", self, "debug_command")
	get_ui().connect("purchase_item", self, "ui_purchase_item")

func get_ui():
	return $UI

remote func on_pre_configure_complete():
	.on_pre_configure_complete()

remote func update_player_position(arr):
	for playerpos in arr:
		var player = players[playerpos.id]
		player.position = player.position.linear_interpolate(playerpos.position, 0.5)
		
		var playerdirection = playerpos.lookDirection
		player.set_look_direction(playerdirection)
	#find bruger med id
	# men denne her har ikke adgang til andre spillere
	#updater den bruger med det id
	#return?

func add_camera_to_player(playerId: int, playerNode: Node2D):
	if playerId == GameData.clientPlayerId:
		var playerCameraScene = load("res://client/game/CameraScene.tscn")
		var playerCamera = playerCameraScene.instance()
		playerNode.add_child(playerCamera)

func get_player_scene():
	return load("res://client/game/ClientPlayer.tscn")

func get_client_player() -> Node2D:
	return get_player(GameData.clientPlayerId)

func single_attack():
	rpc_id(1, "single_attacked")

func auto_attack(start : bool):
	rpc_id(1, "auto_attacked", start)

func load_lobby():
	get_tree().change_scene("res://client/lobby/ClientLobby.tscn")

remote func resource_amount_changed(resources = get_client_player().resources, oldResources : Array = get_client_player().resources):
	# create difference array
	var differenceArray = []
	for i in range(len(oldResources)):
		differenceArray.push_back(resources[i] - oldResources[i])
	get_client_player().resources = resources
	# update UI
	get_ui().set_resources(resources)
	show_visual_resource_change(differenceArray, get_client_player())

func show_visual_resource_change(differenceArray: Array, player : Node2D = get_client_player()):
	for i in range(len(differenceArray)):
		var amount = differenceArray[i]
		if amount == 0:
			# ignore it
			continue
		var resourceSplash = ResourceSplash.instance()
		var newPos = player.position + Vector2(0, -50)
		# TODO: add some random variation
		resourceSplash.init(newPos, amount, i)
		add_child(resourceSplash)

remote func on_ammo_changed(amount: int):
	# update weapon
	get_client_player().get_weapon().ammo = amount
	# update ui
	get_ui().set_ammo(amount)

remote func on_spawn_weapon(weaponType : String, id : String = UUID.v4(), position : Vector2 = Vector2.ZERO):
	# Create weapon with id
	print("got spawn weapon from server")
	spawn_weapon(weaponType, id, position)

remote func on_player_pickup_weapon(playerId : int, weaponId : String, weaponData : Dictionary):
	var weapon = entities[weaponId]
	weapon.update_from_weapon_data(weaponData)
	players[playerId].on_pickup_weapon(weapon)
	# after updating the weapon, the ui should also be updated
	get_ui().set_ammo(weaponData.ammo)

remote func on_spawn_projectile(position: Vector2, direction: Vector2, projectileType: String, projectileId: String, knockbackFactor : float, damage: int):
	.on_spawn_projectile(position, direction, projectileType, projectileId, knockbackFactor, damage)

remote func on_projectile_hit(projectileId):
	.on_projectile_hit(projectileId)

remote func on_projectile_despawn(projectileId):
	.on_projectile_despawn(projectileId)

func debug_command(command, args = []):
	print("sending debug command")
	if GameData.debug == true:
		rpc_id(1, "debug_command", command, args)

remote func end_game():
	if get_tree().get_rpc_sender_id() == 1 or get_tree().is_network_server():
		.end_game()

remote func on_player_dead(playerId: int):
	var player = get_player(playerId)
	.player_dead(player)

remote func on_flag_captured(playerId: int):
	var clientPlayer = get_client_player()
	if clientPlayer.id != playerId:
		.on_flag_captured(playerId)
		return
	var oldResources = clientPlayer.resources.duplicate()
	.on_flag_captured(playerId)
	resource_amount_changed(clientPlayer.resources, oldResources)

func ui_purchase_item(itemId):
	rpc("purchase_item", itemId)

remote func on_update_weapon_on_player(weaponId, playerId):
	var weapon = entities[weaponId]
	var player = get_player(playerId)
	.update_weapon_on_player(weapon, player)

remote func on_deduct_cost(playerId, cost):
	if GameData.clientPlayerId != playerId:
		return
	var player = get_player(playerId)
	var oldResources = player.resources.duplicate()
	.on_deduct_cost(player, cost)
	# update ui
	resource_amount_changed(player.resources, oldResources)

remote func on_start_reload(weaponId : String):
	var weapon = entities[weaponId]
	# print("Got reloading weapon from server, id: " + weaponId)
	weapon.start_reload_animation()

remote func on_weapon_attack(weaponId : String):
	var weapon = entities[weaponId]
	weapon.start_attack_animation()

remote func on_spawn_resource_drop(position: Vector2, type: int, amount: int, oldPosition: Vector2, id : String):
	var _resourceDrop = .spawn_resource_drop(position, type, amount, id)
	# TODO: make animation with the help of oldPositon

remote func on_resource_drop_pickup(resourceDropId, playerId):
	var resourceDrop = entities[resourceDropId]
	var player = get_player(playerId)
	.resource_drop_pickup(resourceDrop, player)