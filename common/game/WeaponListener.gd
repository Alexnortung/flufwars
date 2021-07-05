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

func on_drop_weapon():
	var weapon = $Weapon
	# remove the weapon from self
	disconnect_weapon(weapon)
	remove_child(weapon)
	# add the weapon to the level
	var level = get_player().get_level()
	level.add_child(weapon)
	weapon.on_drop()


func connect_weapon(weapon = $Weapon):
	# $Weapon.connect("single_attack", self, "single_attack")
	weapon.connect("auto_attack", self, "auto_attack")
	weapon.connect("weapon_auto_attack", self, "weapon_auto_attack")

func disconnect_weapon(weapon = $Weapon):
	weapon.disconnect("auto_attack", self, "auto_attack")
	weapon.disconnect("weapon_auto_attack", self, "weapon_auto_attack")

func single_attack():
	emit_signal("single_attack")

func auto_attack(start : bool):
	emit_signal("auto_attack", start)

func weapon_auto_attack():
	emit_signal("weapon_auto_attack")

func get_player():
	return get_parent()