extends Node

# Do any client specific setup here
# Then launch into your first scene
var cmdlineArgs = OS.get_cmdline_args()
var serverAddress = "127.0.0.1"
var defaultPlayerName = "A Player"
var autoconnect = false

func _ready():
	run_checks()
	if autoconnect:
		get_tree().connect('connected_to_server', self, 'on_connected_to_server')
		ClientNetwork.join_game(serverAddress, defaultPlayerName)
		return
	get_tree().change_scene("res://client/main_menu/MainMenu.tscn")

func run_checks():
	check_address()
	check_player_name()
	check_autoconnect()
	GameData.config.playerName = defaultPlayerName
	GameData.config.address = serverAddress
	GameData.config.autoconnect = autoconnect

func check_arg(searchString) -> bool:
	var index = Utilities.pool_string_array_find(cmdlineArgs, searchString)
	return index >= 0

func check_next(searchString) -> Array:
	var index = Utilities.pool_string_array_find(cmdlineArgs, searchString)
	if index < 0:
		return [false]
	if len(cmdlineArgs <= index + 1):
		return [false]
	return [true, cmdlineArgs[index + 1]]

func check_address() -> bool:
	var check = check_next("--address")
	if !check[0]:
		return false
	serverAddress = check[1]
	return true

func check_player_name() -> bool:
	var check = check_next("--player-name")
	if !check[0]:
		return false
	defaultPlayerName = check[1]
	return true

func check_autoconnect() -> bool:
	var check = check_arg("--autoconnect")
	autoconnect = check
	return check

func on_connected_to_server():
	get_tree().change_scene("res://client/lobby/ClientLobby.tscn")
