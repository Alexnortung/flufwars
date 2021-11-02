extends "res://common/game/ResourceSpawners/BaseResourceSpawner.gd"

func _ready():
	update_label()

func on_pickup():
	.on_pickup()
	update_label()

func on_spawn_resource():
	.on_spawn_resource()
	update_label()

func update_label():
	$Label.text = str(resourceAmount)
