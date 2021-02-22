extends Node2D
# This signal will tell whether the player is currently attacking or not.
signal auto_attack
# This signal will tell that the weapon has attacked (Used by server to spawn projectiles and update state)
signal weapon_auto_attack

enum {
	ATTACK_TYPE_SINGLE,
	ATTACK_TYPE_AUTO,
}

var lastFramePressed = false
var isPressed = false

var attackType = ATTACK_TYPE_AUTO
export var cooldown : float = 0.5
var isAttacking = false
var isReady = true # Is true when the cooldown is stopped
var ammo : int = INF # Infinite ammo for base weapon
var isReloading : bool = false
export var maxAmmo : int = INF
export var reloads : int = INF

### Private functions ###
func _ready():
	ammo = maxAmmo
	$CooldownTimer.connect("timeout", self, "on_cooldown_finished")

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
	if isReloading || !isAttacking || !isReady:
		return false
	on_attack()
	return true

### Helper functions ###
func stop_cooldown():
	$CooldownTimer.stop()


### Public functions ###

### On events ###

func on_reload_finish():
	isReloading = false
	try_attack()

func on_cooldown_finish():
	isReady = true
	try_attack()

# called when the weapon is ready to attack, the weapon is firing and the cooldown has timed out.
func on_attack():
	# reset timer
	$CooldownTimer.start(cooldown)
	# print("cooldown timer started")
	isReady = false
	ammo -= 1
	emit_signal("weapon_auto_attack")
