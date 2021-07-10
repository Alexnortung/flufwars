extends Control

export var closeable : bool = true setget closable_changed
export var hasCloseButton : bool = true

func _ready():
	set_close_button_visible(hasCloseButton)

func closable_changed(value: bool):
	pass

func set_close_button_visible(visible : bool):
	$CloseButton.visible = visible

func close_window():
	self.visible = false

func show_window():
	self.visible = true

func _input(event):
	if !self.visible:
		return
	if event.is_action_pressed("close_window"):
		# close window
		close_window()
		accept_event()