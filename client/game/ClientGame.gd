extends "res://common/game/Game.gd"

func _ready():
	var clientPlayer = get_client_player()
	$Countdown.connect("countdown_updated", get_ui(), "countdown_updated")
	$Countdown.connect("countdown_finished", get_ui(), "countdown_finished")
	clientPlayer.connect("single_attack", self, "single_attack")
	clientPlayer.connect("auto_attack", self, "auto_attack")
	$DebugUI.connect("debug_command", self, "debug_command")

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

remote func resource_amount_changed(resources):
	get_client_player().resources = resources
	# update UI
	get_ui().set_resources(resources)

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

func debug_command(command, args):
	print("sending debug command")
	if GameData.debug == true:
		rpc_id(1, "debug_command", command, args)

remote func end_game():
	if get_tree().get_rpc_sender_id() == 1 or get_tree().is_network_server():
		.end_game()

remote func on_player_dead(playerId: int):
		.on_player_dead(playerId)

remote func on_flag_captured(playerId: int):
		.on_flag_captured(playerId)
