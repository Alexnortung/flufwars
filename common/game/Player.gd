extends KinematicBody2D

var acc : int = 4000
var maxSpeed  : int = 500
var motion : Vector2 = Vector2.ZERO
var id

#func _physics_process(delta):
#	if is_network_master():
#		var velocity := Vector2.ZERO
#		if Input.is_action_pressed("ui_down"):
#			velocity.y += SPEED
#		if Input.is_action_pressed("ui_up"):
#			velocity.y -= SPEED
#		if Input.is_action_pressed("ui_left"):
#			velocity.x -= SPEED
#		if Input.is_action_pressed("ui_right"):
#			velocity.x += SPEED
#		
#		velocity = move_and_slide(velocity)
#		
#		rpc_unreliable_id(1, "network_update", velocity)

func set_player_name(playerName: String):
	$NameLabel.text = playerName

func set_id(id):
	self.id = id

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
	

	



