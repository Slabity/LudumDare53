extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/main_level.tscn")


func _on_options_button_pressed():
	print("TODO: OptionsButton pressed()")


# Quit game
func _on_quit_button_pressed():
	get_tree().quit()
