extends PanelContainer

signal expand
signal close

var expanded : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		# Change text
		# emit event
		if expanded:
			get_toggle_text().set_text("Close")
			get_toggle_icon().set_text("-")
			emit_signal("expand")
		else:
			get_toggle_text().set_text("Expand")
			get_toggle_icon().set_text("+")
			emit_signal("close")
		expanded = !expanded


func get_toggle_text():
	return $HBoxContainer.get_node("ToggleText")

func get_toggle_icon():
	return $HBoxContainer.get_node("ToggleIcon")
