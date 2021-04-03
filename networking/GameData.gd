extends Node

var clientPlayerId: int
var players = {}
var teams = []
var mapInfo

var debug = false

var defaultMap = "beams"

var gameShopData

var mapsAvailable = {
	beams = "res://common/game/levels/Beams/Beams.gd",
	level1 = "res://common/game/levels/level1/Level1.gd",
}

var restarted = false

const PLAYER_ID = "id"
const PLAYER_NAME = "name"

func _init():
	# Set default level data
	var selectedMapDataPath = mapsAvailable[defaultMap]
	set_map_info(selectedMapDataPath)
	# load shopData
	gameShopData = load("res://common/game/shop/ShopData.gd").new()

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
	print("Generating team structure")
	var teamsInLevel = mapInfo.teamsInLevel
	teams = []
	for i in range(teamsInLevel):
		var team = { players = {}, color = mapInfo.colorDic[i].code, index = i }
		teams.append(team)

func assign_player_to_team(teamIndex: int, playerId):
	var team = teams[teamIndex]
	var player = players[playerId]
	if player.team != null:
		remove_player_from_team(player.team, player)
	team.players[player.id] = player
	player.team = team


func remove_player_from_team(team, player):
	print("removing from team")
	var newPlayers = teams[team.index].players.erase(player.id)

func remove_team_from_player(team, player):
	players[player.id].team = null


func write_team_dump():
	print("############################################\n############################################")
	for team in teams:
		print(team)
	print("############################################\n############################################")

func write_player_dump():
	print("############################################\n############################################")
	for player in players:
		print(player)
	print("############################################\n############################################")

func reset():
	self.players = {}
	
func set_map_info(path):
	mapInfo = load(path).new()
	generate_team_structure()
