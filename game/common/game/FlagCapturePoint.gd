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

	# get the team of the player
	var teamIndex = self.get_parent().teamIndex

	# checking if the team is the right one
	var playerNode = body.get_player_node()
	if playerNode.teamIndex == teamIndex: 
		playerNode.start_capture()
	return 

func on_exit(body : Node2D):
	if !is_player(body):
		return
	# stop capture
	var playerNode = body.get_player_node()
	playerNode.stop_capture()
