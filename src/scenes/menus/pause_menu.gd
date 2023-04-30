extends Control

signal exit_game

@onready var current_menu = $MainButtons


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			unpause()
		else:
			pause()


func switch_to_menu(menu_name: String):
	current_menu.hide()
	current_menu = get_node(menu_name)
	current_menu.show()


func _on_resume_button_pressed():
	unpause()


func _on_settings_button_pressed():
	switch_to_menu("SettingsMenu")


func _on_exit_to_main_menu_button_pressed():
	unpause()
	exit_game.emit()


func _on_settings_menu_exit_menu():
	switch_to_menu("MainButtons")


func pause():
	get_tree().paused = true
	show()


func unpause():
	get_tree().paused = false
	hide()
