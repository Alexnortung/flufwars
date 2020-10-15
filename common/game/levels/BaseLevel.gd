extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal flag_picked_up

# Called when the node enters the scene tree for the first time.
func _ready():
	for teamNode in self.get_children():
		print("BaseLevel: teamnode Name:" + teamNode.Name)
		teamNode.flag.connect("flag_picked_up", self, "flag_picked_up")


func flag_picked_up(flag, player):
	print("BaseLevel: flag picked up")
	emit_signal("flag_picked_up", flag, player)
