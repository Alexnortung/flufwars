extends "res://common/game/weapons/BaseWeapon.gd"

var projectile = "base_projectile"

# Accuracy: between 0 and 1
# if accuracy is 0, then the gun will shoot a projectile in a random direction
#   ± 45 degree from the target
# if accuracy is 1 it will always shoot straight.
export(float, 0.0, 1.0)var accuracy : float = 0.99
var rng = RandomNumberGenerator.new()

func add_random_accuracy(direction: Vector2) -> Vector2:
	var max_radians = (1.0 - accuracy) * PI / 4 # degrees
	var random_accuracy_radians = rng.randf_range(-max_radians, max_radians)
	return direction.rotated(random_accuracy_radians)
