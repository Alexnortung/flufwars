extends CanvasLayer

var buttons : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	$ToggleButton.connect("expand", self, "expand")
	$ToggleButton.connect("close", self, "close")
	buttons = [
		["spawn pistol (not working test)", funcref(self, "spawn_pistol"), []],
	]
	create_buttons()

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
	print("spawning pistol")
