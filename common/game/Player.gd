extends KinematicBody2D

const projectileSpawnOffset = 100
const progressBarScene = preload("res://common/game/ProgressBar.tscn")

var acc : int = 4000
var maxSpeed  : int = 500
var motion : Vector2 = Vector2.ZERO
var id : int
var teamIndex : int
var pickedUpFlag : Node2D = null
var dead : bool = false
var health : int = 100
const initHealth : int = 100
var captureTime : float = 2.0
const knockbackTime : float = 0.2 # can be changed to be more dynamic
var knockbackTimeLeft : float = 0.0
# const knockbackDefaultDisatance : float = 20000.0
# var knockbackDistance : float = 20000.0
const knockbackDefaultSpeed : float = 800.0
var knockbackSpeed :float = 800.0
# var knockbackDistanceLeft : int = 50
var knockbackDirection : Vector2 = Vector2.UP # should be normalized

var lookDirectionOffset: int = 45

var captureProgress : Node2D = null
var playerSpawn : Node2D

var primaryWeaponSlot : Node2D = null
var secondaryWeaponSlot : Node2D = null
# 0 = primary | 1 = secondary
var activeWeaponSlot : int = 0

signal take_damage
signal single_attack
signal auto_attack # state change
signal weapon_auto_attack # there should be spawned a projectile
signal player_dead # server signal
signal flag_captured #server signal
signal pickup_resource #server signal
signal pickup_weapon # server signal
signal timeout

var resources = [
	0,
	0,
	0,
]

func _physics_process(delta):
	# handle knockback
	# if knockbackTimeLeft > 0.0:
	# 	handleKnockback(delta)
	pass

func _process(delta):
	animate_sprite()
	animate_weapon()
	
func _ready():
	# self.connect("body_entered", self, "pickup")
	self.set_meta("tag", "player")
	$Weapon.connect("single_attack", self, "single_attack")
	$Weapon.connect("weapon_auto_attack", self, "weapon_auto_attack")
	$Weapon.connect("auto_attack", self, "auto_attack")

func set_player_name(playerName: String):
	$NameLabel.text = playerName

func has_flag():
	return pickedUpFlag != null

func set_picked_up_flag(flag):
	pickedUpFlag = flag

func init(id : int, teamIndex : int, playerSpawnNode):
	self.id = id
	self.teamIndex = teamIndex
	self.playerSpawn = playerSpawnNode

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


func spawn():
	self.position = self.playerSpawn.position

func kill_player(is_dead):
	dead = is_dead
	set_process(!is_dead)
	set_physics_process(!is_dead)
	set_process_input(!is_dead)
	self.call_deferred("set_collision", is_dead)
	self.set_visible(!is_dead)
	if has_flag():
		pickedUpFlag.on_flag_drop()
	pickedUpFlag = null
	spawn()

func set_collision(value: bool):
	$WorldCollider.set_disabled(value)
	$InteractiveKinematicBody/InteractiveCollider.set_disabled(value)

#virtual function
func update_health(newHealth: int):
	pass

func take_damage(damage:int):
	emit_signal("take_damage", self.id, health-damage)

func single_attack():
	if self.dead:
		return
	emit_signal("single_attack")

func get_weapon():
	return $Weapon.get_node_or_null("Weapon")

func auto_attack(start):
	emit_signal("auto_attack", start)

func set_attacking(start):
	self.get_weapon().set_attacking(start)

func weapon_auto_attack():
	if self.dead:
		return
	emit_signal("weapon_auto_attack")

func get_direction():
	var mousePos = get_viewport().get_mouse_position()
	var screenCenter = get_viewport().size / 2
	var vectorBetweenPoints = mousePos - screenCenter
	return vectorBetweenPoints

func get_normalized_direction():
	return get_direction().normalized()
	
func animate_sprite():
	var look_direction_x = $Weapon.position.x 
	if look_direction_x <= 0 && (motion == Vector2.ZERO):
		$PlayerAnim.play("base_left")
	elif look_direction_x > 0 && (motion == Vector2.ZERO):
		$PlayerAnim.play("base_right")
	elif look_direction_x >= 0 && (motion != Vector2.ZERO):
		$PlayerAnim.play("walk_right")
	elif look_direction_x < 0 && (motion != Vector2.ZERO):
		$PlayerAnim.play("walk_left")
		
func animate_weapon():
	if !has_weapon():
		return
	var angle = $Weapon.position.angle()
	var lookDirectionX = $Weapon.position.x 
	$Weapon/Weapon.animate_weapon(angle, lookDirectionX)
	

func set_look_direction(direction : Vector2):
	$Weapon.position = direction * lookDirectionOffset

func get_projectile_spawn_position() -> Vector2:
	return self.position + (get_direction() * projectileSpawnOffset)

func spawn_progress(time, callback: String, args = []):
	var progressBarNode = progressBarScene.instance()
	$ProgressBars.add_child(progressBarNode)
	progressBarNode.start(time)
	progressBarNode.connect("timeout", self, callback, args)
	return progressBarNode

func kill_progress_bar(bar: Node2D):
	bar.stop()
	bar.queue_free()
	
func start_capture():
	if !has_flag():
		return
	captureProgress = spawn_progress(captureTime, "flag_capture")

func stop_capture():
	if captureProgress == null:
		return
	kill_progress_bar(captureProgress)
	captureProgress = null

# called when timer runs out
func flag_capture():
	kill_progress_bar(captureProgress)
	captureProgress = null
	print("Flag has been captured")
	emit_signal("flag_captured")

# called from remote / server
func flag_captured():
	if captureProgress != null:
		kill_progress_bar(captureProgress)
		captureProgress = null
	# destroy flag
	pickedUpFlag.isTaken = true
	pickedUpFlag.queue_free()
	pickedUpFlag = null


func resource_pickup(resourceSpawner: Node2D):
	emit_signal("pickup_resource", resourceSpawner)

func resource_collected(key, amount: int):
	resources[key] += amount

func resource_spent(key, amount: int):
	resources[key] -= amount

func has_weapon() -> bool:
	return primaryWeaponSlot != null || secondaryWeaponSlot != null

func has_specific_weapon(weapon : Node2D) -> bool:
	if weapon.weaponSlot == weapon.weaponSlots.PRIMARY_WEAPON or weapon.weaponSlot == weapon.weaponSlots.PRIMARY_WEAPON:
		return true
	return false

func try_pickup_weapon(weapon : Node2D):
	# called from BaseWeapon
	# happens on client and server side
	# should be redirected to server game with signal
	if has_specific_weapon(weapon):
		return false

	emit_signal("pickup_weapon", weapon)
	return true

func find_weapon_switch(weapon : Node2D) -> void:
	if weapon.weaponSlot == weapon.weaponSlots.PRIMARY_WEAPON:
		primaryWeaponSlot = weapon
	
	if weapon.weaponSlot == weapon.weaponSlots.SECONDARY_WEAPON:
		secondaryWeaponSlot = weapon

# This is called on the server and client to sync the new weapon
func on_pickup_weapon(weapon: Node2D):
	$Weapon.update_weapon(weapon)
	weapon.on_pickup(self)
	find_weapon_switch(weapon)

func switch_weapon(weapon_id : int):
	var weapon : Node2D = null

	if weapon_id == 0: 
		weapon = primaryWeaponSlot
	else:
		weapon = secondaryWeaponSlot

	$Weapon.remove_child(get_node("Weapon"))
	$Weapon.add_child(weapon)

func knockback(knockbackFactor : float, _knockbackDirection : Vector2):
	if dead:
		return
	knockbackTimeLeft = knockbackTime
	knockbackSpeed = knockbackDefaultSpeed * knockbackFactor
	knockbackDirection = _knockbackDirection
	# remove edge collision
	set_egde_collision(false)

func apply_knockback(delta):
	if knockbackTimeLeft <= 0.0:
		return
	var knockbackVector = knockbackSpeed * knockbackDirection
	motion += knockbackVector
	motion = motion.clamped(max(knockbackSpeed, maxSpeed))
	knockbackTimeLeft -= delta
	if knockbackTimeLeft <= 0.0:
		set_egde_collision(true)
		if checkPlayerOutOfBounds():
			update_health(0)

func checkPlayerOutOfBounds():
	var level = get_node("../../Level")
	var tilemap = level.get_node("TileMap")
	var nodeV = tilemap.world_to_map(self.position)
	var cell = tilemap.get_cell(nodeV.x, nodeV.y)

	for x in level.outOfBoundsTileIds:
		if cell == x:
			return true
	return false

func set_egde_collision(value : bool):
	set_collision_mask_bit(3, value)
