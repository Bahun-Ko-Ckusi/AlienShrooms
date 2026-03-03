extends Control

@onready var single_player_btn: Button = $VBoxContainer/SinglePlayerBtn
@onready var host_game_btn: Button = $VBoxContainer/HostGameBtn
@onready var join_game_btn: Button = $VBoxContainer/JoinGameBtn
@onready var settings_btn: Button = $VBoxContainer/SettingsBtn
@onready var quit_btn: Button = $VBoxContainer/QuitBtn


func _ready() -> void:
	single_player_btn.grab_focus()


func _on_single_player_pressed() -> void:
	GameManager.start_game(false)


func _on_host_game_pressed() -> void:
	var error := MultiplayerManager.host_game()
	if error == OK:
		GameManager.start_game(true)
	else:
		push_error("Failed to host game: %s" % error)


func _on_join_game_pressed() -> void:
	# For now, connect to localhost.
	# TODO: Add a dialog to enter IP address
	var error := MultiplayerManager.join_game("127.0.0.1")
	if error == OK:
		GameManager.start_game(true)
	else:
		push_error("Failed to join game: %s" % error)


func _on_settings_pressed() -> void:
	# TODO: Open settings menu
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
