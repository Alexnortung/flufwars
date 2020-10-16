extends KinematicBody2D

const projectileSpawnOffset = 100

var acc : int = 4000
var maxSpeed  : int = 500
var motion : Vector2 = Vector2.ZERO
var id : int
var teamIndex : int
var pickedUpFlag : Node2D = null
var dead : bool = false
var health : int = 100

var lookDirectionOffset: int = 45

var playerSpawn : Node2D
signal take_damage
signal single_attack
signal auto_attack # state change
signal weapon_auto_attack # there should be spawned a projectile

func _physics_process(delta):
	pass

func _ready():
	# self.connect("body_entered", self, "pickup")
	self.set_meta("tag", "player")
	$Weapon.connect("single_attack", self, "single_attack")
	$Weapon.connect("weapon_auto_attack", self, "weapon_auto_attack")
	$Weapon.connect("auto_attack", self, "auto_attack")
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

func single_attack():
	# print("Player: gun_fire")
	emit_signal("single_attack")

func get_weapon():
	return $Weapon.get_node("Weapon")

func auto_attack(start):
	print("Player: auto_attack: " + str(start))
	emit_signal("auto_attack", start)

func set_attacking(start):
	self.get_weapon().set_attacking(start)

func weapon_auto_attack():
	print("Player: weapon auto attack")
	emit_signal("weapon_auto_attack")

func get_direction():
	var mousePos = get_viewport().get_mouse_position()
	var playerPos = self.position
	var vectorBetweenPoints = mousePos - playerPos
	return vectorBetweenPoints

func get_normalized_direction():
	return get_direction().normalized()
	
func animate_sprite():
	var mouse_x = get_viewport().get_mouse_position().x
	if mouse_x < self.position.x && (motion == Vector2.ZERO):
		$AnimatedSprite.play("base_left")
	elif mouse_x > self.position.x && (motion == Vector2.ZERO):
		$AnimatedSprite.play("base_right")
	elif mouse_x > self.position.x && (motion != Vector2.ZERO):
		$AnimatedSprite.play("walk_right")
	elif mouse_x > self.position.x && (motion != Vector2.ZERO):
		$AnimatedSprite.play("walk_left")
func get_projectile_spawn_position() -> Vector2:
	return self.position + (get_direction() * projectileSpawnOffset)
