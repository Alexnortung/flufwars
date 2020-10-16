extends KinematicBody2D

var acc : int = 4000
var maxSpeed  : int = 500
var motion : Vector2 = Vector2.ZERO
var id : int
var teamIndex : int
var pickedUpFlag : Node2D = null
var dead : bool = false
var health : int = 100

var playerSpawn : Node2D
signal take_damage
signal gun_fire

func _ready():
	# self.connect("body_entered", self, "pickup")
	self.set_meta("tag", "player")
	$Weapon.connect("gun_fire", self, "gun_fire")
	pass # Replace with function body.

func set_player_name(playerName: String):
	$NameLabel.text = playerName

func has_flag():
	return pickedUpFlag != null

func set_picked_up_flag(flag):
	pickedUpFlag = flag

func init(id : int, teamIndex : int, playerSpawnNode):
	self.id = id
	self.teamIndex = teamIndex
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

func update_health(newHealth: int):
	health = newHealth
	should_die()

func take_damage(damage:int):
	emit_signal("take_damage", self.id, health-damage)

func should_die():
	if health <= 0 && !dead:
		dead = true

func gun_fire():
	print("Player: gun_fire")
	emit_signal("gun_fire")

func get_weapon():
	return $Weapon.get_node("Weapon")
