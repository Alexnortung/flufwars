extends Area2D

var playersInside = []
var maxResources = 32
var resourceAmount = 0

signal spawn_resource

func _ready():
	self.connect("body_entered", self, "body_entered")
	self.connect("body_exited", self, "body_exited")
	$Timer.connect("timeout", self, "spawn_resource")

func validate_player(node : Node2D):
	return node.get_meta("tag") == "player"

func body_entered(body):
	if !validate_player(body):
		return
	if playersInside.find(body) != -1:
		return
	playersInside.append(body)

func body_exited(body):
	if !validate_player(body):
		return
	var playerIndex = playersInside.find(body)
	if playerIndex == -1:
		return
	playersInside.erase(playerIndex)


func spawn_resource():
	emit_signal("spawn_resource")
	if playersInside.size() > 0:
		return
	if resourceAmount >= maxResources:
		return
	resourceAmount += 1