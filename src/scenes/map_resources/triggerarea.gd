extends Area2D

@export var one_shot = false

@onready var collision = $CollisionShape2D
@onready var panel = $Panel


func disable():
	set_deferred("monitoring", false)
	panel.visible = false


func _on_body_entered(_body: Node2D):
	if one_shot:
		disable()
