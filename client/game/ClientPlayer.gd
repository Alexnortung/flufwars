extends "res://common/game/Player.gd"

func _physics_process(delta):
	if is_network_master():
		var axis = get_input_axis()
		if axis != Vector2.ZERO:
			apply_movement(axis * acc *  delta)
		apply_friction(acc * delta, axis)
		motion = move_and_slide(motion)
		rpc_unreliable_id(1, "network_update", axis)

		var normalizedDirection = get_normalized_direction()
		set_look_direction(normalizedDirection)
		rpc_unreliable_id(1, "on_player_change_direction", normalizedDirection)

		check_switch_weapon()

func update_health(newHealth: int):
	health = newHealth
		
func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return axis.normalized()

func check_switch_weapon():
	if Input.is_action_just_pressed("primary_weapon_selection"):
		print("swtich to weapon 1 clicked")
		rpc_id(1, "player_switch_weapon", 0)
	if Input.is_action_just_pressed("secondary_weapon_selection"):
		print("swtich to weapon 2 clicked")
		rpc_id(1, "player_switch_weapon", 1)