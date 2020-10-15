extends Node

signal flag_picked_up

# Called when the node enters the scene tree for the first time.
func _ready():
	var teamIndex = 0
	for teamNode in self.get_children():
		var flagNode = teamNode.get_node("Flag")
		flagNode.connect("flag_picked_up", self, "flag_picked_up")
		teamNode.teamIndex = teamIndex
		flagNode.teamIndex = teamIndex
		teamIndex += 1

func flag_picked_up(flag, player):
	print("BaseLevel: flag picked up")
	emit_signal("flag_picked_up", flag, player)

func get_team(teamIndex):
	return self.get_children()[teamIndex]

func get_flag(teamIndex):
	return self.get_team(teamIndex).get_node("Flag")
