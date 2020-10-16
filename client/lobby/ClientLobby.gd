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

func _on_Lobby_draw():
	var screen_size = get_viewport().size
	var amount_teams = $Teams.get_child_count()
	var team_rect_size = $Teams.get_child(0).get_rect().size.x
	$Teams.rect_position = Vector2((screen_size.x/2)-((amount_teams*team_rect_size)/1.75), screen_size.y/10)
	$StartButton.rect_global_position = screen_size-(screen_size/10)
