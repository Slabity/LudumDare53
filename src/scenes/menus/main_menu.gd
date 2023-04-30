extends Control

signal play_game
signal exit_menu

@onready var current_menu = $MainButtons


func switch_to_menu(menu_name: String):
	current_menu.hide()
	current_menu = get_node(menu_name)
	current_menu.show()


func _on_play_button_pressed():
	play_game.emit()
	


func _on_options_button_pressed():
	switch_to_menu("SettingsMenu")


func _on_quit_button_pressed():
	exit_menu.emit()


func _on_settings_menu_exit_menu():
	switch_to_menu("MainButtons")
