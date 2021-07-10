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
	apply_knockback(delta)
	motion = move_and_slide(motion)

	#print_tree_pretty()

	$Weapon.position = server_direction * lookDirectionOffset
	
func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = server_axis.x
	axis.y = server_axis.y
	return axis.normalized()

func update_health(newHealth: int):
	health = newHealth
	should_die()

func should_die():
	if health <= 0 && !dead:
		self.get_node("RespawnTimer").start(2)
		emit_signal("player_dead", self.id)
		

remote func on_player_change_direction(normalized_direction):
	server_direction = normalized_direction

func get_direction():
	return server_direction.normalized()

func get_projectile_direction():
	var weapon = get_weapon()
	var dir = get_direction()
	if weapon == null:
		return dir
	return weapon.add_random_accuracy(dir)

remote func player_switch_weapon(id : int):
	switch_weapon(id)
	rpc("switch_weapon", id)