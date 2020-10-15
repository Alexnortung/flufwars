extends Node2D
signal gun_fire

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_child_count() > 0:
		connect_weapons()

func update_weapon(weapon: Node2D):
	$Weapon.replace_by(weapon)
	weapon.set_name("Weapon")
	connect_weapons()

func connect_weapons():
	$Weapon.connect("gun_fire", self, "gun_fire")
	$Weapon.connect("attack", self, "attack")

func gun_fire():
	emit_signal("gun_fire", $Weapon)
