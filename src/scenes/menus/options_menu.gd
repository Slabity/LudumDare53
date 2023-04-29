extends Control

@onready var current_menu = $MainOptions


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func switch_to_menu(menu_name: String):
	current_menu.hide()
	current_menu = get_node(menu_name)
	current_menu.show()


# Main settings menu


func _on_audio_button_pressed():
	switch_to_menu("AudioOptions")


func _on_video_button_pressed():
	print("TODO: VideoButton pressed()")


func _on_main_back_button_pressed():
	print("TODO: MainBackButton pressed()")


# Audio settings menu


func save_audio_settings():
	var vol_master = $MasterSlider.value()
	var vol_music = $MusicSlider.value()
	var vol_sfx = $SFXSlider.value()


func _on_master_slider_value_changed(value: float):
	var msg = "TODO: MasterSlider value_changed({value})"
	print(msg.format({"value": value}))


func _on_music_slider_value_changed(value: float):
	var msg = "TODO: MusicSlider value_changed({value})"
	print(msg.format({"value": value}))


func _on_sfx_slider_value_changed(value: float):
	var msg = "TODO: SFXSlider value_changed({value})"
	print(msg.format({"value": value}))


func _on_audio_back_button_pressed():
	switch_to_menu("MainOptions")
