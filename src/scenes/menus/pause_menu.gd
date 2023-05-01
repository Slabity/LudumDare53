extends Control

signal exit_game

@onready var current_menu = $MainButtons


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			unpause()
		else:
			pause()


func open_main():
	switch_to_menu($MainButtons)
	$MainButtons/ResumeButton.grab_focus()


func open_settings():
	switch_to_menu($SettingsMenu)
	$SettingsMenu.open_main_settings()


func switch_to_menu(menu: Node):
	current_menu.hide()
	current_menu = menu
	current_menu.show()


func _on_resume_button_pressed():
	unpause()


func _on_settings_button_pressed():
	open_settings()


func _on_exit_to_main_menu_button_pressed():
	unpause()
	exit_game.emit()


func _on_settings_menu_exit_menu():
	open_main()


func pause():
	get_tree().paused = true
	open_main()
	show()


func unpause():
	get_tree().paused = false
	hide()
