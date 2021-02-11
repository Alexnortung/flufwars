extends "res://common/game/Game.gd"

func _ready():
	var clientPlayer = get_player(GameData.clientPlayerId)
	clientPlayer.connect("single_attack", self, "single_attack")
	clientPlayer.connect("auto_attack", self, "auto_attack")

func on_pre_configure_complete():
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

func get_player_scene():
	return load("res://client/game/ClientPlayer.tscn")

func single_attack():
	rpc_id(1, "single_attacked")

func auto_attack(start : bool):
	rpc_id(1, "auto_attacked", start)

func load_lobby():
	get_tree().change_scene("res://client/lobby/ClientLobby.tscn")

remote func remote_on_pre_configure_complete():
	on_pre_configure_complete()

remote func remote_on_flag_picked_up(teamIndex : int, playerId : int):
	on_flag_picked_up(teamIndex, playerId)

remote func remote_on_take_damage(playerId: int, newHealth: int):
	on_take_damage(playerId, newHealth)

remote func remote_on_spawn_projectile(position: Vector2, direction: Vector2, projectileType: String, projectileId: String):
	on_spawn_projectile(position, direction, projectileType, projectileId)

remote func remote_on_respawn_player(playerId: int):
	on_respawn_player(playerId)

remote func remote_on_player_dead(playerId: int):
	on_player_dead(playerId)