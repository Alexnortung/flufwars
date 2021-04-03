extends KinematicBody2D

signal hit
signal age_timeout

export var damage = 50
export var speed = 100
var knockbackFactor
var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var id : String
var _should_emit = true

func init(position : Vector2, direction : Vector2, knockbackFactor, id = UUID.v4()):
	self.position = position
	self.direction = direction.normalized()
	self.velocity = self.direction * speed
	self.id = id
	self.knockbackFactor = knockbackFactor

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_meta("tag", "projectile")
	$Area2D.connect("body_entered", self, "hit")
	$AgeTimer.connect("timeout", self, "age_timeout")
	$AgeTimer.start()

func hit(body: Node):
	if !_should_emit:
		return
	self.dont_emit_hit()
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

func age_timeout():
	emit_signal("age_timeout", self)
