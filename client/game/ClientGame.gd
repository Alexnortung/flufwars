extends "res://common/game/Game.gd"

func _ready():
	pass

remotesync func on_pre_configure_complete():
	print("All clients are configured. Starting the game.")
	get_tree().paused = false

remote func update_player_position(obj):
	for player in $Players.get_children():
		if player.id == obj.id:
			player.position = obj.position
	#find bruger med id
	# men denne her har ikke adgang til andre spillere
	#updater den bruger med det id
	#return?