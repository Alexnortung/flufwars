extends Node2D

signal timeout

func _ready():
	$Timer.connect("timeout", self, "timeout")

func start(time: float):
	$Timer.start(time)

func stop():
	$Timer.stop()

func _physics_process(delta):
	set_bar()

func set_bar():
	var inner = $InnerBar
	var initialScale = 0.195
	var progress = ($Timer.time_left / $Timer.wait_time)
	var scale = initialScale * progress
	# var initialPosX = 9.881
	inner.get_node("InnerBarSprite").scale.x = scale

func timeout():
	emit_signal("timeout")
