extends CanvasLayer

signal debug_command

const _infinityChar = "∞"

var _ammo = 0
var _reloads = INF

func _ready():
	pass

func set_ammo(amount):
	_ammo = amount
	_set_ammo_label()

func set_reloads(amount):
	_reloads = amount
	_set_ammo_label()

func _set_ammo_label():
	var updatedLabel = _generate_ammo_label()
	$AmmoPanel/Label.text = updatedLabel

func _generate_ammo_label():
	var updatedLabel = ""
	if _ammo == INF:
		updatedLabel = _infinityChar
		return updatedLabel
	updatedLabel += str(_ammo) + "/"
	if _reloads == INF:
		updatedLabel += _infinityChar
	else:
		updatedLabel += str(_reloads)
	return updatedLabel

func _get_resource_container():
	return $ResourcesPanel/HBoxContainer

func set_resource1(amount):
	_get_resource_container().get_node("Label").text = str(amount)
func set_resource2(amount):
	_get_resource_container().get_node("Label2").text = str(amount)
func set_resource3(amount):
	_get_resource_container().get_node("Label3").text = str(amount)

func set_resources(arr: Array):
	set_resource1(arr[0])
	set_resource2(arr[1])
	set_resource3(arr[2])
