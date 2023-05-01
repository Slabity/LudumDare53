extends VBoxContainer

signal pressed(choice)

@onready var button = $Button
@onready var description = $Description

var choice


func set_power(power):
	choice = power
	match power:
		PlayerPower.GRAPPLE, PlayerPower.GRAPPLE_KICK:
			button.icon = load("res://assets/player/power/chain.png")
		PlayerPower.DASH, PlayerPower.DASH_KICK:
			button.icon = load("res://assets/player/power/dash.png")
	description.text = PlayerPower.new().loss_description(power)


func _on_button_pressed():
	pressed.emit(choice)
