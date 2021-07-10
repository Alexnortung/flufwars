extends "res://client/main_menu/BaseWindow.gd"

func get_player_name():
	return $CenterContainer/VBoxContainer/PlayerName.text

func get_server_ip():
	return $CenterContainer/VBoxContainer/ServerIp.text

func _on_ConnectButton_pressed():
	connect_to_server(get_player_name(), get_server_ip())

func connect_to_server(playerName: String, serverIp: String):
	ClientNetwork.join_game(serverIp, playerName)
