extends Node2D

@onready var player = $Player

var choice_menu = preload("res://src/scenes/menus/delivery/choice_menu.tscn")


func _on_choice_body_entered(_body: Node2D):
	var instance = choice_menu.instantiate()
	player.add_child(instance)
	instance.update_choices(player.powers)
	instance.selected.connect(remove_power)


func remove_power(power):
	player.remove_power(power)
