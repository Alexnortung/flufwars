extends Node2D
signal single_attack
signal auto_attack
signal weapon_auto_attack

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_node("Weapon"):
		connect_weapon()

func update_weapon(weapon: Node2D):
	if weapon.get_parent() != null:
		weapon.get_parent().remove_child(weapon)
	if has_node("Weapon"):
		$Weapon.replace_by(weapon)
	else:
		add_child(weapon)
	weapon.set_name("Weapon")
	connect_weapon(weapon)

func connect_weapon(weapon = $Weapon):
	# $Weapon.connect("single_attack", self, "single_attack")
	weapon.connect("auto_attack", self, "auto_attack")
	weapon.connect("weapon_auto_attack", self, "weapon_auto_attack")

func single_attack():
	emit_signal("single_attack")

func auto_attack(start : bool):
	#print("WeaponListener: auto attack: " + str(start))
	emit_signal("auto_attack", start)

func weapon_auto_attack():
	#print("WeaponListener: weapon auto attack")
	emit_signal("weapon_auto_attack")
