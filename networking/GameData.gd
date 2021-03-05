extends Node

var clientPlayerId: int
var players = {}
var teams = []
var mapInfo

var mapsAvailable = {
	beams = "res://common/game/levels/Beams/Beams.gd",
	level1 = "res://common/game/levels/level1/Level1.gd",
}

const PLAYER_ID = "id"
const PLAYER_NAME = "name"

func _init():
	# Set default level data
	var selectedMapDataPath = mapsAvailable[mapsAvailable.keys()[0]]
	set_map_info(selectedMapDataPath)

func create_new_player(playerId: int, playerName: String) -> Dictionary:
	return { PLAYER_ID: playerId, PLAYER_NAME: playerName, team = null }

func remove_player(playerId : int):
	var player = players[playerId]
	remove_player_from_team(player.team, player)
	players.erase(playerId)

func add_player(playerId: int, playerName: String):
	var newPlayer = create_new_player(playerId, playerName)
	self.players[playerId] = newPlayer

func generate_team_structure():
	#var teamColors = map_info.teamColors
	var teamsInLevel = mapInfo.teamsInLevel
	# var playersPerTeam = mapInfo.playersPerTeam
	teams = []
	for i in range(teamsInLevel):
		var team = { players = {}, color = mapInfo.colorDic[i].code, index = i }
		teams.append(team)

func assign_player_to_team(teamIndex: int, playerId):
	var team = teams[teamIndex]
	var player = players[playerId]
	if player.team != null:
		# var tempTeam = player.team
		# print("removing player " + str(playerId) + " from " + str(tempTeam.index))
		remove_player_from_team(player.team, player)
	# print("assigning player " + str(playerId) + " to " + str(teamIndex))
	team.players[player.id] = player
	player.team = team


func remove_player_from_team(team, player):
	print("removing from team")
	print(team)
	var newPlayers = teams[team.index].players.erase(player.id)
	print(team)
	print(newPlayers)


func write_team_dump():
	print("############################################\n############################################")
	for team in teams:
		print(team)
	print("############################################\n############################################")

func write_player_dump():
	print("printing player dump")
	print("############################################\n############################################")
	for player in players:
		print(player)
	print("############################################\n############################################")

func reset():
	self.players = {}
	
func set_map_info(path):
	mapInfo = load(path).new()
	generate_team_structure()
