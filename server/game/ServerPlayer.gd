extends "res://common/game/Player.gd"

var server_axis = {
	x = 0,
	y = 0,
}

puppet func network_update(networkAxis: Vector2):
	server_axis = networkAxis

func _physics_process(delta):
	var axis = get_input_axis()
	if axis != Vector2.ZERO:
		apply_movement(axis * acc *  delta)
	apply_friction(acc * delta, axis)
	motion = move_and_slide(motion)
	#Behøves ikke at sende noget right?
	#    rpc_unreliable_id(1, "network_update", axis)
	
func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = server_axis.x
	axis.y = server_axis.y
	return axis.normalized()
