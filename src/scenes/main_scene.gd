extends Control


func _ready():
	$CenterContainer/MainMenu.open_main()


func _on_main_menu_play_game():
	get_tree().change_scene_to_file("res://src/scenes/levels/full_world.tscn")


func _on_main_menu_exit_menu():
	get_tree().quit()
