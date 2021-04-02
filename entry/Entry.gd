extends Node

# Entry point for the whole app
# Determine the type of app this is, and load the entry point for that type
func _ready():
	print("Application started")
	if OS.has_feature("server") || "--server" in OS.get_cmdline_args():
		print("Is server")
		check_debug()
		get_tree().change_scene("res://server/ServerEntry.tscn")
	elif OS.has_feature("client") || "--client" in OS.get_cmdline_args():
		print("Is client")
		check_debug()
		get_tree().change_scene("res://client/ClientEntry.tscn")
	# When running from the editor, this is how we'll default to being a client
	else:
		print("Could not detect application type! Defaulting to client.")
		check_debug()
		get_tree().change_scene("res://client/ClientEntry.tscn")
		# get_tree().change_scene("res://server/ServerEntry.tscn")

func check_debug():
	if "--test" in OS.get_cmdline_args():
		GameData.debug = true
