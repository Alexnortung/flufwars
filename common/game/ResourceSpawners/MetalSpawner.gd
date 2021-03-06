extends "res://common/game/ResourceSpawners/BaseResourceSpawner.gd"

func _ready():
	resourceType = 2
	resourceSpawnTime = 10.0
	resourceAmount = 5
	spawnAmount = 8
	maxResources = 128
	resourceSpawnTime = 4.0

func on_pickup():
	.on_pickup()
	update_label()

func on_spawn_resource():
	.on_spawn_resource()
	update_label()

func update_label():
	$Label.text = str(resourceAmount)
