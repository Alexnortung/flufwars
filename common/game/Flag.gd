extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var picked_up_player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "pickup")
	pass # Replace with function body.

func pickup(node):
	picked_up_player = node
	print("picking up the flag")
	
func _physics_process(delta):
	if picked_up_player != null:
		self.position = picked_up_player.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
