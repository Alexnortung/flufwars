extends "res://common/game/Game.gd"

func _ready():
	var clientPlayer = get_player(GameData.clientPlayerId)
	clientPlayer.connect("single_attack", self, "single_attack")
	clientPlayer.connect("auto_attack", self, "auto_attack")

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
		print("player has been assigned a camera")
		var playerCameraScene = load("res://client/game/CameraScene.tscn")
		var playerCamera = playerCameraScene.instance()
		playerNode.add_child(playerCamera)

func get_player_scene():
	return load("res://client/game/ClientPlayer.tscn")

func single_attack():
	rpc_id(1, "single_attacked")

func auto_attack(start : bool):
	rpc_id(1, "auto_attacked", start)


