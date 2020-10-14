extends "res://common/game/Player.gd"

func _physics_process(delta):
    if is_network_master():
        var axis = get_input_axis()
        if axis != Vector2.ZERO:
            apply_movement(axis * acc *  delta)
        apply_friction(acc * delta, axis)
        motion = move_and_slide(motion)
        #Behøves ikke at sende noget right?
        rpc_unreliable_id(1, "network_update", axis)
	
func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return axis.normalized()
