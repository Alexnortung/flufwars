extends CanvasLayer

signal debug_command
signal purchase_item(itemId)

const _infinityChar = "∞"

var _ammo = 0
var _reloads = INF

func _ready():
	$MiddleText.get_node("Timer").connect("timeout", self, "on_middle_text_timeout")
	_get_shop_button().connect("pressed", self, "toggle_shop")
	_get_shop_ui().connect("purchase_item", self, "purchase_item")

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

func _get_right_corner():
	return $RightSide/RightCorner/RightCornerHBox

func _get_shop_ui():
	return $RightSide/ShopUI

func _get_resource_container():
	return _get_right_corner().get_node("ResourcesPanel/HBoxContainer")

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

func countdown_finished():
	show_middle_message("FLUF!", 2)

func countdown_updated(timeLeft):
	$MiddleText.show()
	if timeLeft <= 0:
		return
	$MiddleText.text = str(timeLeft)

func show_middle_message(message : String, time : float = 2.0):
	$MiddleText.text = message
	$MiddleText.show()
	$MiddleText.get_node("Timer").start(time)

func on_middle_text_timeout():
	$MiddleText.hide()
	$MiddleText.get_node("Timer").stop()

func _get_shop_button():
	return _get_right_corner().get_node("ShopButton")

func toggle_shop():
	_get_shop_ui().visible = !_get_shop_ui().visible

func purchase_item(itemId):
	emit_signal("purchase_item", itemId)
