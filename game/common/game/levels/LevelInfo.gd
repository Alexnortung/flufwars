# This file should be abstract and extended by level info files
# for each level

var colorDic = {}
var teamColors = 0
var playersPerTeam = 0
var teamsInLevel = 0
var levelScenePath : String
var outOfBoundsTileIds = [-1]

func createTeamColor(colorName, colorCode):
	var flagImage = load("res://assets/flag/" + colorName + "_flag.png")
	var colorCodeObj = Color(colorCode)
	var playerAnimObj = load("res://assets/players/"+colorName+"_player.tres")
	return { color = colorName, code = colorCodeObj, flagImage = flagImage, playerAnim = playerAnimObj }
