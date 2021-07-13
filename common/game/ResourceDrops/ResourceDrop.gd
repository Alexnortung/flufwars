extends Node2D

var resourceIcons = [
	preload("res://assets/resources/emerald.png"),
	preload("res://assets/resources/diamond.png"),
	preload("res://assets/resources/A4.png"),
	preload("res://assets/flag/purple_flag.png"),
]

var amount : int = 0

func init(position : Vector2, type : int, amount):
	assert(type >= 0)
	assert(type < len(resourceIcons))
	self.amount = amount
	self.position = position
	$TextureRect.texture = resourceIcons[type]
	# print("setting position to: " + str(self.position))

func on_enter(body):
	# only players
	pass
