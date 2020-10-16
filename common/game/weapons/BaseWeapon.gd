extends Node2D

signal single_attack
signal auto_attack

enum {
	ATTACK_TYPE_SINGLE,
	ATTACK_TYPE_AUTO,
}

var lastFramePressed = false
var isPressed = false

var attackType = ATTACK_TYPE_SINGLE
var cooldown = 3.5
var isAttacking = false
var isReady = true

func _ready():
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
		emit_signal("auto_attck", true)
	elif !isPressed && lastFramePressed:
		# emit that the gun should stop shooting
		emit_signal("auto_attck", false)

func set_attacking(start):
	isAttacking = start
	if isReady:
		# shoot
		start_auto_attack()


func on_cooldown_finished():
	isReady = true
	if attackType == ATTACK_TYPE_AUTO && isAttacking:
		start_auto_attack()

func start_auto_attack():
	# emit auto attack
	emit_signal("weapon_auto_attack")
	on_attack()

func on_attack():
	# reset timer
	$CooldownTimer.start(cooldown)
	isReady = false
