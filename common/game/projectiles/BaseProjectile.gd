extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var damage = 1
var speed = 100
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

func init(position : Vector2, direction : Vector2):
	self.position = position
	self.direction = direction.normalized()
	self.velocity = self.direction * speed

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_meta("tag", "projectile")
	$Area2D.connect("body_entered", self, "hit")

func hit(body: Node):
	if body.get_meta("tag") == "player":
		body.take_damage(damage)
	self.queue_free()

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		hit(collision.collider)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
