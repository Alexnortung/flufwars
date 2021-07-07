extends CanvasLayer

signal debug_command

var buttons : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameData.debug:
		$ToggleButton.connect("expand", self, "expand")
		$ToggleButton.connect("close", self, "close")
		buttons = [
			["spawn pistol", funcref(self, "spawn_pistol"), []],
			["Print tree", funcref(self, "_print_tree"), []],
			["Make me rich", funcref(self, "make_me_rich"), []],
		]
		create_buttons()
	else:
		get_node_or_null("ToggleButton").visible = false

func create_buttons():
	for props in buttons:
		var button_text = props[0]
		var function = props[1]
		var args = props[2]
		var button = Button.new()
		button.set_text(button_text)
		$Menu.add_child(button)
		button.connect("pressed", self, "call_funcref", [function, args])

func call_funcref(function, args):
	function.call_funcv(args)

func expand():
	$Menu.show()

func close():
	$Menu.hide()

func spawn_pistol():
	emit_signal("debug_command", "spawn_pistol", [])

func _print_tree():
	get_tree().get_root().print_tree_pretty()
	emit_signal("debug_command", "print_tree")

func make_me_rich():
	emit_signal("debug_command", "make_me_rich")