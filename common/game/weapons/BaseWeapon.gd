# Abstract "class" should not be instantiated :)

extends Node2D
# This signal will tell whether the player is currently attacking or not.
signal auto_attack

# This signal will tell that the weapon has attacked (Used by server to spawn projectiles and update state)
signal weapon_auto_attack

# This signal will help the server to tell the clients that the player is reloading
# signal start_reload

enum {
	ATTACK_TYPE_SINGLE,
	ATTACK_TYPE_AUTO,
}

var lastFramePressed = false
var isPressed = false

var attackType = ATTACK_TYPE_AUTO
export var cooldown : float = 0.5
export var reloadTime: float = 2
var isAttacking = false
var isReady = true # Is true when the cooldown is stopped
var ammo : int = INF # Infinite ammo for base weapon
var isReloading : bool = false
export var maxAmmo : int = INF
export var reloads : int = INF
var id : String
var lastHeldBy : int
var isDropped : bool = true
var recentlyDropped : bool = false

# Constructor
func init(id = UUID.v4(), position : Vector2 = Vector2.ZERO):
	self.id = id
	self.position = position

### Private functions ###
func _ready():
	ammo = maxAmmo
	self.set_meta("tag", "weapon")
	$Area2D.connect("body_entered", self, "on_enter") # TODO: make server connect this
	$CooldownTimer.connect("timeout", self, "on_cooldown_finished")
	$ReloadTimer.connect("timeout", self, "on_reload_finish")

func _physics_process(delta):
	isPressed = Input.is_action_pressed("fire")
	if attackType == ATTACK_TYPE_AUTO:
		auto_fire_logic()
	lastFramePressed = isPressed

func auto_fire_logic():
	if isPressed && !lastFramePressed:
		# emit the the gun should start to shoot
		emit_signal("auto_attack", true)
	elif !isPressed && lastFramePressed:
		# emit that the gun should stop shooting
		emit_signal("auto_attack", false)

# Try attack should be called when the player tries to attack or the cooldown has run out.
func try_attack():
	# If conditions are met then fire
	# print("trying to attack:")
	# print("reloading:" + str(isReloading))
	# print("attacking:" + str(isAttacking))
	# print("isReady:" + str(isAttacking))
	# print("ammo:" + str(ammo))
	if isReloading || !isAttacking || !isReady || ammo <= 0:
		return false
	on_attack()
	return true

func start_reload():
	isReloading = true
	$ReloadTimer.start(reloadTime)

### Helper functions ###
func stop_cooldown():
	$CooldownTimer.stop()


### Public functions ###

func update_from_weapon_data(weaponData: Dictionary):
	self.ammo = weaponData.ammo
	self.reloads = weaponData.reloads

### On events ###

func on_reload_finish():
	isReloading = false
	ammo = maxAmmo
	$ReloadTimer.stop()
	try_attack()

func on_cooldown_finished():
	isReady = true
	if !isAttacking:
		stop_cooldown()
	try_attack()

# called when the weapon is ready to attack, the weapon is firing and the cooldown has timed out.
func on_attack():
	# reset timer
	$CooldownTimer.start(cooldown)
	# print("cooldown timer started")
	isReady = false
	ammo -= 1
	emit_signal("weapon_auto_attack")
	if ammo <= 0:
		start_reload()

# Called on server side to help determine the try_attack function
func set_attacking(active : bool):
	isAttacking = active
	if active:
		try_attack()

### Drop/Pickup logic ###
# This function should be called on the server side
func on_enter(body: Node):
	if !isDropped:
		return
	if body.get_meta("tag") == "player":
		body.try_pickup_weapon(self)

# Should only be called from player that picks this up
func on_pickup(player: Node):
	isDropped = false
	lastHeldBy = player.id
	recentlyDropped = false
	self.position = Vector2.ZERO

func on_drop_timer_finish():
	recentlyDropped = false
