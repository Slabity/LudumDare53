extends CenterContainer

signal selected(power)

@onready var button_container = $VBoxContainer/HBoxContainer
var button_scene = preload("res://src/scenes/menus/delivery/choice_button.tscn")

var instances = []


func _ready():
	pause()


# Given player's current power
func update_choices(powers):
	if PlayerPower.DASH_KICK in powers:
		add_choice(PlayerPower.DASH_KICK)
	elif PlayerPower.DASH in powers:
		add_choice(PlayerPower.DASH)

	if PlayerPower.GRAPPLE_KICK in powers:
		add_choice(PlayerPower.GRAPPLE_KICK)
	elif PlayerPower.GRAPPLE in powers:
		add_choice(PlayerPower.GRAPPLE)

	if instances.is_empty():
		# We shouldn't be here.
		unpause()


func add_choice(power):
	var instance = button_scene.instantiate()
	button_container.add_child(instance)
	instance.set_power(power)
	instance.pressed.connect(choice_pressed)
	instances.append(instance)


func choice_pressed(power):
	print(power)
	selected.emit(power)
	unpause()


func pause():
	get_tree().paused = true


func unpause():
	get_tree().paused = false
	queue_free()
