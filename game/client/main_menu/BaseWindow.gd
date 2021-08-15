extends Control

export var closeable : bool = true setget closable_changed
export var hasCloseButton : bool = true
export var isOpen : bool = false

func _ready():
	set_close_button_visible(hasCloseButton)
	if isOpen:
		show_window()
	else:
		close_window()

func closable_changed(value: bool):
	pass

func set_close_button_visible(visible : bool):
	$CloseButton.visible = visible

func close_window():
	self.visible = false
	set_process_input(false)

func show_window():
	self.visible = true
	set_process_input(true)

func _input(event):
	if !self.visible:
		return
	if event.is_action_pressed("close_window"):
		# close window
		close_window()
		accept_event()
		get_tree().set_input_as_handled()

func _on_Close_utton_pressed():
	close_window()
