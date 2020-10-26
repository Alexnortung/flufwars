extends Area2D

var playersInside = []
var maxResources = 32
var resourceAmount = 10
var resourceSpawnTime : float = 2.0
var resourceType = 0
export var id : String = "" # Always set this when creating a new resource spawner

signal spawn_resource
signal split_resources

func _ready():
	assert(id != "")
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
	emit_signal("split_resources")

func body_exited(body: Node2D):
	print("body exited of resource spawner")
	if !validate_player(body):
		return
	var playerIndex = playersInside.find(body)
	print(playerIndex)
	if playerIndex == -1:
		return
	playersInside.remove(playerIndex)
	print(playersInside)



# called on timer timeout - handled by server
func spawn_resource():
	emit_signal("spawn_resource")
	if playersInside.size() > 0:
		# split resources
		emit_signal("split_resources")

# update state from rpc call from server
func on_spawn_resource():
	if resourceAmount >= maxResources:
		# do nothing, no more capacity
		return
	resourceAmount += 1

func on_pickup():
	# do stuff

	resourceAmount = 0

func get_split_amount() -> int:
	return resourceAmount

func get_players_inside():
	return playersInside

func update_player_resources():
	var splitAmount = get_split_amount()
	for player in playersInside:
		player.resources[resourceType] += splitAmount
