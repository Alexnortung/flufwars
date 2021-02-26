extends Node

var commands : Dictionary

func _ready():
	commands = {
		spawn_pistol = funcref(self, "spawn_pistol"),
	}


# entry point from parent
func command(command : String, player : Node2D, args : Array = []):
	print("running command: " + command)
	args.push_front(player)
	if commands.has(command):
		commands[command].call_funcv(args)

# spawn base gun
func spawn_pistol(player : Node2D):
	print("Spawning pistol")
	get_node("..").server_spawn_weapon("pistol", player.position)
