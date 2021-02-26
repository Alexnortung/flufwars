extends "res://common/game/Game.gd"

func _ready():
	var clientPlayer = get_client_player()
	clientPlayer.connect("single_attack", self, "single_attack")
	clientPlayer.connect("auto_attack", self, "auto_attack")
	$DebugUI.connect("debug_command", self, "debug_command")

func get_ui():
	return $UI

remotesync func on_pre_configure_complete():
	print("All clients are configured. Starting the game.")
	get_tree().paused = false

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

remote func on_player_pickup_weapon(playerId : int, weaponId : String):
	var weapon = entities[weaponId]
	players[playerId].on_pickup_weapon(weapon)

func debug_command(command, args):
	print("sending debug command")
	rpc_id(1, "debug_command", command, args)
