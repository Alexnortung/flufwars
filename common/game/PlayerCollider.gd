extends KinematicBody2D

func _ready():
	self.set_meta("tag", "player")

func get_player_node():
	return get_node("..")

func take_damage(damage:int):
	get_player_node().take_damage(damage)

func knockback(knockbackFactor : float, _knockbackDirection : Vector2):
	get_player_node().knockback(knockbackFactor, _knockbackDirection)
