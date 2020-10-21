extends Area2D

func _ready():
	self.connect("body_entered", self, "on_enter")
	self.connect("body_exited", self, "on_exit")


func is_player(body : Node2D) -> bool:
	return body.get_meta("tag") == "player"

func on_enter(body: Node2D):
	if !is_player(body):
		return
	# start capture
	body.start_capture()

func on_exit(body : Node2D):
	if !is_player(body):
		return
	# stop capture
	body.stop_capture()
