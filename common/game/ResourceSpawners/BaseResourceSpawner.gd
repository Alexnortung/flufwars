extends Area2D

var playersInside = []
var maxResources = 32
var resourceAmount = 10
var resourceSpawnTime : float = 2.0
var resourceType = 0
var id : int = -1

signal spawn_resource
signal player_entered

# func _init(id: int):
# 	self.id = id
func _ready():
	self.connect("body_entered", self, "body_entered")
	self.connect("body_exited", self, "body_exited")
	$Timer.connect("timeout", self, "spawn_resource")
	$Timer.start(resourceSpawnTime)

func validate_player(node : Node2D):
	return node.get_meta("tag") == "player"

func body_entered(body):
	if !validate_player(body):
		return
	if playersInside.find(body) != -1:
		return
	playersInside.append(body)
	# this signal should be handled by server
	emit_signal("player_entered")

func body_exited(body):
	if !validate_player(body):
		return
	var playerIndex = playersInside.find(body)
	if playerIndex == -1:
		return
	playersInside.erase(playerIndex)



# called on timer timeout - handled by server
func spawn_resource():
	if playersInside.size() > 0:
		# split resources
		emit_signal("split_resources")
		return
	emit_signal("spawn_resource")

# update state from rpc call from server
func on_spawn_resource():
	if resourceAmount >= maxResources:
		# do nothing, no more capacity
		return
	resourceAmount += 1

func on_pickup():
	# do stuff

	resourceAmount = 0
