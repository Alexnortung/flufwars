extends KinematicBody2D

signal hit

var damage = 50
var speed = 100
var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var id
var _should_emit = true

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
	if !_should_emit:
		return
	if body.get_meta("tag") == "projectile":
		body.dont_emit_hit()
		emit_signal("hit", body, self)
	emit_signal("hit", self, body)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		hit(collision.collider)

# use this to tell collided projectiles that this projctile will emit hit for it.
func dont_emit_hit():
	_should_emit = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
