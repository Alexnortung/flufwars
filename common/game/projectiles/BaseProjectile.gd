extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var damage = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "hit")
	self.set_meta("tag", "projectile")

func hit(body: Node):
	if body.get_meta("tag") == "player":
		body.take_damage(damage)
	self.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
