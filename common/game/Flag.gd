extends Node2D

signal flag_picked_up

const respawnTime = 7.0

var pickedUpPlayer = null
var teamIndex : int
var initialPosition : Vector2
var dropped : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.initialPosition = self.position
	self.connect("body_entered", self, "pickup")
	$RespawnBar.connect("timeout", self, "on_respawn_timer_end")

func is_picked_up():
	return pickedUpPlayer != null

func pickup(node):
	# Tell all players over the network that the player picked up the flag.
	if node.teamIndex != self.teamIndex && !self.is_picked_up() && !node.has_flag():
		print("Flag: flag picked up")
		emit_signal("flag_picked_up", self, node)
	
func _physics_process(delta):
	# Continously place flag ontop of the player who is carrying the flag 
	if pickedUpPlayer != null:
		follow_player()
	elif dropped:
		# move bar
		set_bar()
 
func set_bar():
	pass
func follow_player():
	self.position = pickedUpPlayer.position
	if pickedUpPlayer.get_direction().x > 0:
		self.rotation = 0.5
	else:
		self.rotation = -0.5

func picked_up(flag, player):
	dropped = false
	pickedUpPlayer = player
	$RespawnBar.set_visible(false)
	player.set_picked_up_flag(flag)
	$RespawnBar.stop()
	print("picking up the flag " + str(flag.teamIndex) + " from player " + str(player.id))


func _on_Flag_draw():
	$FlagShape/FlagSprite.texture = GameData.mapInfo.colorDic[teamIndex].flagImage

func on_flag_drop():
	$RespawnBar.set_visible(true)
	dropped = true
	self.rotation = 0
	self.pickedUpPlayer = null
	$RespawnBar.start(respawnTime)

func on_respawn_timer_end():
	print("Respawn timer ended")
	$RespawnBar.stop()
	$RespawnBar.set_visible(false)
	dropped = false
	self.position = self.initialPosition
