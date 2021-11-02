extends Node

# Entry point for the whole app
# Determine the type of app this is, and load the entry point for that type
func _ready():
	print("Application started 123")
	check_debug()
	if OS.has_feature("server") || "--server" in OS.get_cmdline_args():
		print("Is server")
		use_server_entry()
	elif OS.has_feature("client") || "--client" in OS.get_cmdline_args():
		print("Is client")
		use_client_entry()
	# When running from the editor, this is how we'll default to being a client
	else:
		print("Could not detect application type! Defaulting to client.")
		use_client_entry()
	
	if !OS.has_feature("client") && !("—no-window" in OS.get_cmdline_args()):
		OS.window_position = Vector2(int(OS.get_cmdline_args()[0]),0)
		# use_server_entry()

func use_server_entry():
	GameData.isClient = false
	get_tree().change_scene("res://server/ServerEntry.tscn")

func use_client_entry():
	GameData.isClient = true
	get_tree().change_scene("res://client/ClientEntry.tscn")

func check_debug():
	if "--test" in OS.get_cmdline_args():
		GameData.debug = true
