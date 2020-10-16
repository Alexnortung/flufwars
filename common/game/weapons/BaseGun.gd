extends "res://common/game/weapons/BaseWeapon.gd"

var projectile = "base_projectile"

func _physics_process(delta):
	if Input.is_action_pressed("fire"):
		fire()

func fire():
	emit_signal("gun_fire")
