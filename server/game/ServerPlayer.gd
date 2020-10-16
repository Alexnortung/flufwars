extends "res://common/game/Player.gd"

var server_axis = {
	x = 0,
	y = 0,
}

var server_direction = Vector2(0,0)

puppet func network_update(networkAxis: Vector2):
	server_axis = networkAxis

func _physics_process(delta):
	var axis = get_input_axis()
	if axis != Vector2.ZERO:
		apply_movement(axis * acc *  delta)
	apply_friction(acc * delta, axis)
	motion = move_and_slide(motion)

	$Weapon.position = server_direction * lookDirectionOffset
	
func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = server_axis.x
	axis.y = server_axis.y
	return axis.normalized()

remote func on_player_change_direction(normalized_direction):
	server_direction = normalized_direction
	print("set server direction")