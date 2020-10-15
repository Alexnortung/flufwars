extends "res://common/lobby/Lobby.gd"

func _ready():
	if not ServerNetwork.is_hosting():
		if not ServerNetwork.host_game():
			print("Failed to start server, shutting down.")
			get_tree().quit()
			return
	
	ClientNetwork.connect("start_game", self, "on_start_game")


func on_start_game():
	get_tree().change_scene("res://server/game/ServerGame.tscn")


remote func join_team(teamIndex: int):
	var playerId = get_tree().get_rpc_sender_id()
	var team = GameData.players[playerId].team

	if team != null:
		if team.index == teamIndex:
			return
		GameData.remove_player_from_team(GameData.teams[teamIndex], GameData.players[playerId])

	if GameData.teams[teamIndex].players.size() < Level1Data.playersPerTeam:
		GameData.assign_player_to_team(teamIndex, playerId)
		rpc("assign_player_to_team", playerId, teamIndex)
		print("Player " + str(playerId) + " joined team " + str(teamIndex))
	# TODO:create error no space on the team
#	emit_signal("assign_player_to_team", teamIndex, playerId)