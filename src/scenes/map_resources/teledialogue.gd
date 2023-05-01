extends Node2D

@onready var label = $Label
@onready var progressBar = $ProgressBar

@export var teleport_duration = 2.0
@export var enabled = false:
	set = set_enabled

signal teleport

var teleporting = false
var telestart


func set_enabled(val):
	enabled = val
	if !val:
		label.visible = false
		progressBar.scale.x = 0.0


func _ready():
	label.visible = false
	progressBar.scale.x = 0.0


func _process(_delta):
	if !enabled:
		return

	if teleporting:
		label.visible = true

		var elapsed = (Time.get_unix_time_from_system() - telestart) / teleport_duration
		progressBar.scale.x = elapsed
		if elapsed > 1.0:
			teleporting = false
			teleport.emit()
	else:
		label.visible = false
		progressBar.scale.x = 0.0


func _input(event):
	if InputMap.event_is_action(event, "Interact"):
		if event.pressed:
			if !teleporting:
				telestart = Time.get_unix_time_from_system()
				teleporting = true
		else:
			teleporting = false
