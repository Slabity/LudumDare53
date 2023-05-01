extends Control

signal exit_menu

@onready var current_menu = $MainSettings
@onready var settings_node = get_node("/root/Settings")
@onready var settings = settings_node.settings


func open_main_settings():
	switch_to_menu($MainSettings)
	$MainSettings/AudioButton.grab_focus()


func open_audio_settings():
	$AudioSettings/Master/Slider.set_value(settings["vol_master"])
	$AudioSettings/Music/Slider.set_value(settings["vol_music"])
	$AudioSettings/SFX/Slider.set_value(settings["vol_sfx"])
	$AudioSettings/Master/Slider.grab_focus()
	switch_to_menu($AudioSettings)


func switch_to_menu(menu: Node):
	current_menu.hide()
	current_menu = menu
	current_menu.show()


# MainSettings signals


func _on_audio_button_pressed():
	open_audio_settings()


func _on_video_button_pressed():
	print("TODO: VideoButton pressed()")


func _on_main_back_button_pressed():
	settings_node.save_settings()
	exit_menu.emit()


# AudioSettings signals


func _on_master_slider_value_changed(value: float):
	settings["vol_master"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))


func _on_music_slider_value_changed(value: float):
	settings["vol_music"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))


func _on_sfx_slider_value_changed(value: float):
	settings["vol_sfx"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(value))


func _on_audio_back_button_pressed():
	open_main_settings()
