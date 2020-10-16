extends "res://common/game/weapons/BaseWeapon.gd"

var projectile = "base_projectile"
var lastFramePressed = false

func _physics_process(delta):
	var isPressed = Input.is_action_pressed("fire")
	if isPressed && !lastFramePressed:
		fire()
	lastFramePressed = isPressed

func fire():
	emit_signal("single_attack")
