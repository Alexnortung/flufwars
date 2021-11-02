extends Node

var commands : Dictionary

func _ready():
	commands = {
		spawn_pistol = funcref(self, "spawn_pistol"),
		print_tree = funcref(self, "_print_tree"),
		make_me_rich = funcref(self, "make_me_rich"),
	}

func get_server_game_node():
	return get_parent()

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

func _print_tree(player):
	get_tree().get_root().print_tree_pretty()

func make_me_rich(player):
	player.resources = [1000000, 1000000, 1000000, 1000000]
	get_server_game_node().resource_amount_changed(player)