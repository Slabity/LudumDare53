extends Control


func _on_main_menu_play_game():
	get_tree().change_scene_to_file("res://src/scenes/main_level.tscn")


func _on_main_menu_exit_menu():
	get_tree().quit()
