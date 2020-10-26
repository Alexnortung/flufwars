extends "res://common/game/ResourceSpawners/BaseResourceSpawner.gd"

func _ready():
	pass

func on_pickup():
	.on_pickup()
	$Label.text = str(resourceAmount)

func on_spawn_resource():
	.on_spawn_resource()
	$Label.text = str(resourceAmount)
