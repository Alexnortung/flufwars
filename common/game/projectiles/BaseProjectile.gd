extends KinematicBody2D

signal hit

var damage = 50
var speed = 100
var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var id

func init(position : Vector2, direction : Vector2, id = UUID.v4()):
	self.position = position
	self.direction = direction.normalized()
	self.velocity = self.direction * speed
	self.id = id

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_meta("tag", "projectile")
	$Area2D.connect("body_entered", self, "hit")

func hit(body: Node):
	emit_signal("hit", self, body)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		hit(collision.collider)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
