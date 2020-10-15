extends Node2D

signal flag_picked_up

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var picked_up_player = null
var teamIndex : int

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "pickup")
	pass # Replace with function body.

func is_picked_up():
	return picked_up_player != null

func pickup(node):
	# picked_up_player = node
	# tell all players over the network that the player picked up the flag.
	if node.teamIndex != self.teamIndex && !self.is_picked_up() && !node.has_flag():
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
	player.set_picked_up_flag(flag)
	print("picking up the flag " + str(flag.teamIndex) + " from player " + str(player.id))
	# print(flag)
	# print(player)
