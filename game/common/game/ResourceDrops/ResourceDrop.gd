extends Node2D

signal on_pickup(body)
signal on_despawn

var picked_up = false

var resourceIcons = [
	preload("res://assets/resources/emerald.png"),
	preload("res://assets/resources/diamond.png"),
	preload("res://assets/resources/A4.png"),
	preload("res://assets/flag/purple_flag.png"),
]

var amount : int = 0
var type : int
var id : String

func init(_position : Vector2, _type : int, _amount, _id : String):
	assert(type >= 0)
	assert(type < len(resourceIcons))
	self.type = _type
	self.amount = _amount
	self.position = _position
	self.id = _id
	$TextureRect.texture = resourceIcons[type]
	# print("setting position to: " + str(self.position))

# When a player gets inside the area, emit a signal that the player picked it up
#   should then be handled by game
func on_enter(body : Node2D):
	# only players
	if (body.get_meta("tag") != "player") || picked_up:
		return
	emit_signal("on_pickup", self, body)
