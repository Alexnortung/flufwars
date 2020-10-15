extends "res://common/game/Game.gd"

func _ready():
	get_player(GameData.clientPlayerId).connect("gun_fire", self, "gun_fire")

remotesync func on_pre_configure_complete():
	print("All clients are configured. Starting the game.")
	get_tree().paused = false

remote func update_player_position(arr):
	for playerpos in arr:
		var player = players[playerpos.id]
		if (playerpos.position - player.position).length() > 1:
			player.position = playerpos.position
	#find bruger med id
	# men denne her har ikke adgang til andre spillere
	#updater den bruger med det id
	#return?

func get_player_scene():
	return load("res://client/game/ClientPlayer.tscn")

func gun_fire():
	rpc_id(1, "gun_fired")


