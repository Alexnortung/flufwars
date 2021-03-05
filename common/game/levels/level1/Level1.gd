extends "res://common/game/levels/LevelInfo.gd"

func _init():
	colorDic[0] = createTeamColor("red", "981D1D")
	colorDic[1] = createTeamColor("green", "40883C")
	colorDic[2] = createTeamColor("blue", "3F28A7")
	colorDic[3] = createTeamColor("orange", "B75923")
	levelScenePath = "res://common/game/levels/level1/Level1.tscn"

	playersPerTeam = 1
	teamsInLevel = 4
