extends KinematicBody2D

var acc : int = 4000
var maxSpeed  : int = 500
var motion : Vector2 = Vector2.ZERO
var id : int
var teamIndex : int

var playerSpawn : Node2D

func set_player_name(playerName: String):
	$NameLabel.text = playerName

func init(id, teamIndex, playerSpawnNode):
	self.id = id
	self.playerSpawn = playerSpawnNode

func apply_friction(amount, axis):
	var norm = motion.normalized() * amount
	if axis.x == 0:
		# apply friction to axis
		if abs(motion.x) > norm.x:
			motion.x -= norm.x
		else:
			motion.x = 0
	if axis.y == 0:
		#apply friction to y axis
		if abs(motion.y) > norm.y:
			motion.y -= norm.y
		else:
			motion.y = 0

func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(maxSpeed)

func spawn():
	self.position = self.playerSpawn.position
