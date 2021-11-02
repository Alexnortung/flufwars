extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var flag : Node2D
var teamIndex : int
# Called when the node enters the scene tree for the first time.
func _ready():
	# connect flag events
	flag = $Flag

func get_resource_spawners():
	return $ResourceSpawners.get_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
