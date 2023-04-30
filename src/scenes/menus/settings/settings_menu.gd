extends Control

signal exit_menu

@onready var current_menu = $MainSettings
@onready var settings_node = get_node("/root/Settings")


func switch_to_menu(menu_name: String):
	current_menu.hide()
	current_menu = get_node(menu_name)
	current_menu.show()


func _on_audio_button_pressed():
	switch_to_menu("AudioSettings")


func _on_video_button_pressed():
	print("TODO: VideoButton pressed()")


func _on_main_back_button_pressed():
	settings_node.save_settings()
	exit_menu.emit()


func _on_audio_settings_exit_menu():
	switch_to_menu("MainSettings")
