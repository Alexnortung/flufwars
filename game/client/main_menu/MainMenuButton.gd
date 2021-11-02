extends Control

var hovering : bool = false setget on_set_hovering

func _on_button_mouse_entered():
	hovering = true
	on_set_hovering(true)

func _on_button_mouse_exited():
	hovering = false
	on_set_hovering(false)

func on_set_hovering(value: bool):
	$MainMenuButton/HoverEffect.visible = value
