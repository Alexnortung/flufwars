extends Control
# TODO: change so nameplates are removed when disconnecting from lobby.
func _ready():
	ClientNetwork.connect("create_player", self, "create_player")
	ClientNetwork.connect("remove_player", self, "remove_player")
	ClientNetwork.connect("assign_player_to_team", self, "assign_player_to_team")

	GameData.reset()

	generate_team_visual_structure()

func create_player(playerId: int):
	print("Creating player in lobby")
	print("############################################################################")
	#var player = GameData.players[playerId]
	var namePlateScene = preload("res://common/lobby/NamePlate.tscn")
	
	var namePlateNode = namePlateScene.instance()
	namePlateNode.set_network_master(playerId)
	namePlateNode.set_name(str(playerId))
	
	var player = GameData.players[playerId]
	namePlateNode.get_node("Name").text = player[GameData.PLAYER_NAME]
	
	$Players.add_child(namePlateNode)

func remove_player(playerId: int):
	var name = "PlayerId_" + str(playerId)
	for child in $Teams.get_children():
		var playersNode = child.get_node_or_null("Players")
		if playersNode != null:
			var playerNode = playersNode.get_node_or_null(name)
			if playerNode != null:
				print("Player removed")
				playerNode.queue_free()
				break

func assign_client_to_team(teamIndex):
	rpc_id(1, "join_team", teamIndex)

remote func assign_player_to_team(playerId, teamIndex, firstTime = false):
	#-1 is only send when we want to join spectators
	if teamIndex == -1:
		#if it is not already on spectator team
		if GameData.players[playerId].team != null:
			var player = GameData.players[playerId]
			remove_player_from_old_team(playerId)
			add_player_to_new_team(playerId, "Spectators")
			GameData.remove_player_from_team(player.team, player)
			GameData.remove_team_from_player(player.team, player)
		return

	# -2 is only send from when the player connects.
	if teamIndex == -2:
		add_player_to_new_team(playerId, "Spectators")
		return

	remove_player_from_old_team(playerId)

	# Update game data
	GameData.assign_player_to_team(teamIndex, playerId)
	add_player_to_new_team(playerId, "Team_" + str(teamIndex))

func remove_player_from_old_team(playerId : int):
	var player = GameData.players[playerId]
	var oldPlayerNamePlates = ""
	if player.team == null:
		oldPlayerNamePlates = $Teams.get_node("Spectators").get_node("Players")
	else:
		var oldTeamIndex = player.team.index
		oldPlayerNamePlates = $Teams.get_node("Team_" + str(oldTeamIndex)).get_node("Players")
	oldPlayerNamePlates.get_node("PlayerId_" + str(playerId)).queue_free()

func add_player_to_new_team(playerId : int, teamNode : String):
	var namePlateScene = preload("res://common/lobby/NamePlate.tscn")

	var namePlate = namePlateScene.instance()
	$Teams.get_node(teamNode).get_node("Players").add_child(namePlate)
	namePlate.set_name("PlayerId_" + str(playerId))
	namePlate.get_node("Name").text = GameData.players[playerId].name
	
func generate_team_visual_structure():
	var teams = GameData.teams

	var i = 0
	for team in teams:
		create_team_scene("Team_" + str(i), i, 25)
		i += 1
	
	# create spectator team
	var teamNode = create_team_node("Spectators", 0, 300)
	teamNode.get_node("JoinButton").connect("pressed", self, "assign_client_to_team", [-1])

func create_team_node(nodeName : String, index : int, y : int):
	var teamScene = load("res://common/lobby/LobbyTeam.tscn")
	var namePlateScene = preload("res://common/lobby/NamePlate.tscn")
	print("creating team")
	var teamNode = teamScene.instance()
	$Teams.add_child(teamNode)
	teamNode.set_name(nodeName)
	var rect = teamNode.get_rect()
	teamNode.rect_position = Vector2(index * (rect.size.x + 50), y)
	return teamNode

func create_team_scene(nodeName : String, index : int, y : int):
	var teamNode = create_team_node(nodeName, index, y)
	teamNode.get_node("TeamFlag").texture = GameData.mapInfo.colorDic[index].flagImage
	teamNode.get_node("JoinButton").text = "Join " + GameData.mapInfo.colorDic[index].color + " team"
	teamNode.get_node("JoinButton").connect("pressed", self, "assign_client_to_team", [index])
