extends Control

signal play_game
signal exit_menu

@onready var current_menu = $MainButtons


func open_main():
	switch_to_menu($MainButtons)
	$MainButtons/PlayButton.grab_focus()


func open_settings():
	switch_to_menu($SettingsMenu)
	$SettingsMenu.open_main_settings()


func switch_to_menu(menu: Node):
	current_menu.hide()
	current_menu = menu
	current_menu.show()


func _on_play_button_pressed():
	play_game.emit()


func _on_options_button_pressed():
	open_settings()


func _on_quit_button_pressed():
	exit_menu.emit()


func _on_settings_menu_exit_menu():
	open_main()
