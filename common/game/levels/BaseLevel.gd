extends Node

signal flag_picked_up
signal spawn_resource

# Called when the node enters the scene tree for the first time.
func _ready():
	var teamIndex = 0
	for teamNode in self.get_children():
		var flagNode = teamNode.get_node("Flag")
		flagNode.connect("flag_picked_up", self, "flag_picked_up")
		teamNode.teamIndex = teamIndex
		flagNode.teamIndex = teamIndex
		teamIndex += 1
		#connect_resource_spawners(teamNode.get_resource_spawners())

func flag_picked_up(flag, player):
	print("BaseLevel: flag picked up")
	emit_signal("flag_picked_up", flag, player)

func get_team(teamIndex):
	#return self.get_children()[teamIndex]
	return self.get_node_or_null(NodePath("Team" + str(teamIndex + 1)))

func get_flag(teamIndex):
	return self.get_team(teamIndex).get_node_or_null("Flag")

func createTeamColor(colorName, colorCode):
	var flagImage = load("res://assets/flag/" + colorName + "_flag.png")
	var colorCodeObj = Color(colorCode)
	var playerAnimObj = load("res://assets/players/"+colorName+"_player.tres")
	#var player_path = "res://assets/player/" + 
	return { color = colorName, code = colorCodeObj, flagImage = flagImage, playerAnim = playerAnimObj }
		
func connect_resource_spawners(resourceSpawners: Array):
	for i in resourceSpawners:
		var resourceSpawner = resourceSpawners[i]
		resourceSpawner.connect("spawn_resource", self, "spawn_resource", [ resourceSpawner ])

func spawn_resource(resourceSpawner: Node2D):
	emit_signal("spawn_resource", resourceSpawner)