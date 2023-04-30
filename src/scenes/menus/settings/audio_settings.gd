extends VBoxContainer

signal exit_menu

@onready var settings_node = get_node("/root/Settings")
@onready var settings = settings_node.settings


func _ready():
	$Master/Slider.set_value(settings["vol_master"])
	$Music/Slider.set_value(settings["vol_music"])
	$SFX/Slider.set_value(settings["vol_sfx"])


func _on_master_slider_value_changed(value: float):
	settings["vol_master"] = value


func _on_music_slider_value_changed(value: float):
	settings["vol_music"] = value


func _on_sfx_slider_value_changed(value: float):
	settings["vol_sfx"] = value


func _on_back_pressed():
	exit_menu.emit()
