extends Node

var resourceSpawners = {}

signal flag_picked_up
signal spawn_resource
signal split_resources

# Called when the node enters the scene tree for the first time.
func _ready():
	var teamIndex = 0
	for i in range(GameData.mapInfo.teamsInLevel):
		var teamNode = get_team(i)
		# if teamNode.get_meta("tag") != "team_node":
		# 	continue
		var flagNode = teamNode.get_node("Flag")
		flagNode.connect("flag_picked_up", self, "flag_picked_up")
		teamNode.teamIndex = teamIndex
		flagNode.teamIndex = teamIndex
		# flagNode.levelNode = self
		teamIndex += 1
		connect_resource_spawners(teamNode.get_resource_spawners())
	# connect_resource_spawners($ResourceSpawners.get_children())

func flag_picked_up(flag, player):
	print("BaseLevel: flag picked up")
	emit_signal("flag_picked_up", flag, player)

func get_team(teamIndex):
	#return self.get_children()[teamIndex]
	return self.get_node_or_null(NodePath("Teams/Team" + str(teamIndex + 1)))

func get_resource_spawner(id : String) -> Node2D:
	return resourceSpawners[id]

func get_flag(teamIndex):
	return self.get_team(teamIndex).get_node_or_null("Flag")

func connect_resource_spawners(_resourceSpawners: Array):
	for resourceSpawner in _resourceSpawners:
		resourceSpawner.connect("spawn_resource", self, "spawn_resource", [ resourceSpawner ])
		resourceSpawner.connect("split_resources", self, "split_resources", [ resourceSpawner ])
		# put the node in a dictionary so it can be accessed much more easily.
		self.resourceSpawners[resourceSpawner.id] = resourceSpawner

func spawn_resource(resourceSpawner: Node2D):
	emit_signal("spawn_resource", resourceSpawner)

func split_resources(resourceSpawner: Node2D):
	emit_signal("split_resources", resourceSpawner)
