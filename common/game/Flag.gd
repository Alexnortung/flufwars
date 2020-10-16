extends Node2D

signal flag_picked_up

var picked_up_player = null
var teamIndex : int
var flag_textures : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "pickup")
	#flag_textures = [load("res://assets/flag/Blue_flag.png"),load("res://assets/flag/Green_flag.png"),load("res://assets/flag/Orange_flag.png"),load("res://assets/flag/Pink_flag.png"),load("res://assets/flag/Purple_flag.png"),load("res://assets/flag/Red_flag.png"),load("res://assets/flag/Turquoise_flag.png"),load("res://assets/flag/Yellow_flag.png")]

func is_picked_up():
	return picked_up_player != null

func pickup(node):
	# Tell all players over the network that the player picked up the flag.
	if node.teamIndex != self.teamIndex && !self.is_picked_up() && !node.has_flag():
		print("Flag: flag picked up")
		emit_signal("flag_picked_up", self, node)
	
func _physics_process(delta):
	# Continously place flag ontop of the player who is carrying the flag 
	if picked_up_player != null:
		self.position = picked_up_player.position
 
func picked_up(flag, player):
	picked_up_player = player
	player.set_picked_up_flag(flag)
	print("picking up the flag " + str(flag.teamIndex) + " from player " + str(player.id))
	# print(flag)
	# print(player)


#func _on_Flag_draw():
#	$FlagShape/FlagSprite.texture = flag_textures[teamIndex]
