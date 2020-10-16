extends Node2D

signal flag_picked_up

var picked_up_player = null
var teamIndex : int

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "pickup")

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
		self.rotation = 0.5
 
func picked_up(flag, player):
	picked_up_player = player
	player.set_picked_up_flag(flag)
	print("picking up the flag " + str(flag.teamIndex) + " from player " + str(player.id))


func _on_Flag_draw():
	$FlagShape/FlagSprite.texture = Level1Data.colorDic[teamIndex].flagImage
