extends "res://common/lobby/Lobby.gd"

func _ready():
	ClientNetwork.connect("start_game", self, "on_start_game")
	
	GameData.clientPlayerId = get_tree().get_network_unique_id()
	# Tell the server about you
	ServerNetwork.register_self(GameData.clientPlayerId, ClientNetwork.localPlayerName)

func _on_StartButton_pressed():
	ClientNetwork.start_game()

func on_start_game():
	get_tree().change_scene("res://client/game/ClientGame.tscn")
