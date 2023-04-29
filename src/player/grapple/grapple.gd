extends Node2D

@onready var raycast = $RayCast2D
@export var grapple_length: float = 170.0

signal grapple_attached(hook_location: Vector2)  # global position
signal grapple_detached


func _input(event: InputEvent) -> void:
	if InputMap.event_is_action(event, "grapple"):
		if event.pressed:
			if event is InputEventMouseButton:
				fire_raycast(get_local_mouse_position())
			elif event is InputEventJoypadButton:
				var target_position = Vector2(
					Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
				)
				# Apply a deadzone. Shoots up by default.
				if target_position.length() < 0.2:
					target_position = Vector2.UP

				fire_raycast(target_position)
		else:
			grapple_detached.emit()


func fire_raycast(target_position):
	raycast.target_position = target_position.normalized() * grapple_length
	raycast.force_raycast_update()

	if raycast.is_colliding():
		grapple_attached.emit(raycast.get_collision_point())
