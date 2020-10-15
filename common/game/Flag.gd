extends Node2D

signal flag_picked_up

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var picked_up_player = null
var teamIndex = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "pickup")
	pass # Replace with function body.

func pickup(node):
	# picked_up_player = node
	# tell all players over the network that the player picked up the flag.
	print("Flag: flag picked up")
	emit_signal("flag_picked_up", self, node)
	
func _physics_process(delta):
	if picked_up_player != null:
		self.position = picked_up_player.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func picked_up(flag, player):
	picked_up_player = player
	print("picking up the flag")
	print(flag)
	print(player)
