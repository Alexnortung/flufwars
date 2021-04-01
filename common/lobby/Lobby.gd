extends Control

func _ready():
	ClientNetwork.connect("create_player", self, "create_player")
	ClientNetwork.connect("remove_player", self, "remove_player")
	ClientNetwork.connect("assign_player_to_team", self, "assign_player_to_team")

	GameData.reset()

	generate_team_visual_structure()

func create_player(playerId: int):
	print("Creating player in lobby")
	#var player = GameData.players[playerId]
	var namePlateScene = preload("res://common/lobby/NamePlate.tscn")
	
	var namePlateNode = namePlateScene.instance()
	namePlateNode.set_network_master(playerId)
	namePlateNode.set_name(str(playerId))
	
	var player = GameData.players[playerId]
	namePlateNode.get_node("Name").text = player[GameData.PLAYER_NAME]
	
	#playerNode.position.x = 100
	#playerNode.position.y = 100
	
	$Players.add_child(namePlateNode)

func remove_player(playerId: int):
	var name = str(playerId)
	for child in $Players.get_children():
		if child.name == name:
			print("Player removed")
			$Players.remove_child(child)
			break

func assign_client_to_team(teamIndex):
	rpc_id(1, "join_team", teamIndex)

remote func assign_player_to_team(playerId, teamIndex, firstTime = false):
	if GameData.players[playerId].team != null && !firstTime:
		# remove player from old team
		var oldTeamIndex = GameData.players[playerId].team.index
		var oldPlayerNamePlates = $Teams.get_node("Team_" + str(oldTeamIndex)).get_node("Players")
		oldPlayerNamePlates.get_node("PlayerId_" + str(playerId)).queue_free()

	# Update game data
	GameData.assign_player_to_team(teamIndex, playerId)
	var namePlateScene = preload("res://common/lobby/NamePlate.tscn")

	var namePlate = namePlateScene.instance()
	$Teams.get_node("Team_" + str(teamIndex)).get_node("Players").add_child(namePlate)
	namePlate.set_name("PlayerId_" + str(playerId))
	namePlate.get_node("Name").text = GameData.players[playerId].name



func generate_team_visual_structure():
	var teams = GameData.teams

	var teamScene = load("res://common/lobby/LobbyTeam.tscn")
	var namePlateScene = preload("res://common/lobby/NamePlate.tscn")
	var i = 0
	for team in teams:
		print("creating team")
		var teamNode = teamScene.instance()
		$Teams.add_child(teamNode)
		teamNode.set_name("Team_" + str(i))
		var rect = teamNode.get_rect()
		teamNode.rect_position = Vector2(i * (rect.size.x + 50), 25)
		teamNode.get_node("TeamFlag").texture = GameData.mapInfo.colorDic[i].flagImage
		teamNode.get_node("JoinButton").text = "Join " + GameData.mapInfo.colorDic[i].color + " team"
		teamNode.get_node("JoinButton").connect("pressed", self, "assign_client_to_team", [i])

#		for playerId in team.players:
#			var player = team.players[playerId]
#			var nameplate = namePlateScene.instance()
#			nameplate.get_node("Name").text = player[(GameData.PLAYER_NAME)]
#			teamNode.get_node("Players").add_child(nameplate)
		i += 1
