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

	# checking if the team is the right one
	if str(body.teamIndex) == body.pickedUpFlag.teamIndex: 
		body.start_capture()
	return 

func on_exit(body : Node2D):
	if !is_player(body):
		return
	# stop capture
	body.stop_capture()
