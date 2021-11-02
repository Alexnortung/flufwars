extends Node2D

signal single_attack
signal auto_attack
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
var isReady = true
var ammo : int = INF # Infinite ammo for base weapon
export var maxAmmo : int = INF
export var reloads : int = INF

func _ready():
	ammo = maxAmmo
	$CooldownTimer.connect("timeout", self, "on_cooldown_finished")

func _physics_process(delta):
	isPressed = Input.is_action_pressed("fire")
	if attackType == ATTACK_TYPE_SINGLE:
		single_fire_logic()
	elif attackType == ATTACK_TYPE_AUTO:
		auto_fire_logic()
	lastFramePressed = isPressed

func attack():
	emit_signal("single_attack")
	on_attack()

func single_fire_logic():
	if isPressed && !lastFramePressed && isReady:
		attack()

func on_attacking(start : bool):
	# start cooldown timer
	pass

func auto_fire_logic():
	if isPressed && !lastFramePressed:
		# emit the the gun should start to shoot
		emit_signal("auto_attack", true)
	elif !isPressed && lastFramePressed:
		# emit that the gun should stop shooting
		emit_signal("auto_attack", false)

func set_attacking(start):
	#print("set_attacking: " + str(start))
	isAttacking = start
	if isReady && start:
		# shoot
		start_auto_attack()


func on_cooldown_finished():
	#print("cooldown finshed, is attacking: " + str(isAttacking))
	isReady = true
	if attackType == ATTACK_TYPE_AUTO && isAttacking:
		# print("firing again")
		start_auto_attack()
	elif attackType == ATTACK_TYPE_AUTO && !isAttacking:
		stop_cooldown()
	elif attackType == ATTACK_TYPE_SINGLE:
		stop_cooldown()

func stop_cooldown():
	$CooldownTimer.stop()

func start_auto_attack():
	# emit auto attack
	# print("auto fired weapon")
	on_attack()
	emit_signal("weapon_auto_attack")

func on_attack():
	# reset timer
	$CooldownTimer.start(cooldown)
	# print("cooldown timer started")
	isReady = false
	ammo -= 1
