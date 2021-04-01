extends Node

signal countdown_finished
signal countdown_updated

var totalTime : int
var timeLeft : int

func _ready():
	$StartCountdownTimer.connect("timeout", self, "on_timer_finish")

#### Public ####

func start(totalTime):
	self.totalTime = totalTime
	timeLeft = totalTime
	emit_signal("countdown_updated", timeLeft)
	start_timer()


#### Private ####

func start_timer():
	$StartCountdownTimer.start(1)

func on_timer_finish():
	timeLeft -= 1
	emit_signal("countdown_updated", timeLeft)
	if timeLeft <= 0:
		$StartCountdownTimer.stop()
		emit_signal("countdown_finished")
		return
	# restart timer
	print("restarting timer")
	start_timer()
