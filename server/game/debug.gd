extends Node

var commands : Dictionary

func _ready():
	commands = {
		spawn_pistol = funcref(self, "spawn_pistol"),
	}


# entry point from parent
func command(command : String, args : Array = []):
	print("running command: " + command)
	if commands.has(command):
		commands[command].call_funcv(args)

# spawn base gun
func spawn_pistol():
	print("Spawning pistol")
	get_node("..").server_spawn_weapon("pistol")
