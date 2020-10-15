extends "res://common/game/Game.gd"

var unreadyPlayers := {}

func _init():
	self.connect("spawn_flag", self, "handle_spawn_flag")

func _ready():
	ClientNetwork.connect("remove_player", self, "remove_player")
	for playerId in GameData.players:
		unreadyPlayers[playerId] = playerId

remote func on_client_ready(playerId):
	print("client ready: %s" % playerId)
	unreadyPlayers.erase(playerId)
	print("Still waiting on %d players" % unreadyPlayers.size())
	
	# All clients are done, unpause the game
	if unreadyPlayers.empty():
		print("Starting the game")
		rpc("on_pre_configure_complete")


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
		arr.append({position = player.position, id = player.id})
	rpc_unreliable("update_player_position", arr)
	#find alle spillere
	#loop hen over dem
	#send deres postioner

func get_player_scene():
	return load("res://server/game/ServerPlayer.tscn")

func handle_spawn_flag(flag):
	print("handling spawn flag")
	flag.connect("flag_picked_up", self, "flag_picked_up")

func flag_picked_up(flag, player):
	print("telling clients, flag was picked up")
	rpc("on_flag_picked_up", flag.teamIndex, player.id)