extends "BaseNetwork.gd"

signal create_player
signal start_game
signal assign_player_to_team

var localPlayerName: String

func join_game(serverIp: String, playerName: String) -> bool:
	
	self.localPlayerName = playerName
	print("player_name" + self.localPlayerName)
	
	var peer = NetworkedMultiplayerENet.new()
	var result = peer.create_client(serverIp, ServerNetwork.SERVER_PORT)
	
	if result == OK:
		get_tree().set_network_peer(peer)
		print("Connecting to server...")
		return true
	else:
		return false


func on_connected_to_server():
	print("Connected to server.")


func register_player(recipientId: int, playerId: int, playerName: String, curPlayerTeam: int):
	rpc_id(recipientId, "on_register_player", playerId, playerName, curPlayerTeam)
	print("sending register data " + str(playerId))


remote func on_register_player(playerId: int, playerName: String, curPlayerTeam: int):
	#print(playerName)
	# TODO: they detect this as being on a team
	print("on_register_player: " + str(playerId))
	GameData.add_player(playerId, playerName)
	if curPlayerTeam != -1:
		print(GameData.players[playerId])
		print(GameData.write_team_dump())
		print(GameData.write_player_dump())
		GameData.assign_player_to_team(curPlayerTeam, playerId)
		emit_signal("assign_player_to_team", playerId, curPlayerTeam, true)

func start_game():
	rpc("on_start_game")


remotesync func on_start_game():
	emit_signal("start_game")
