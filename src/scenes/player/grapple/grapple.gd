extends Node2D

# Note that the grapple visuals are entirely cosmetic.
# We check for hook collision immediately on click.

@onready var raycast = $RayCast2D
@onready var links = $Links
@onready var hook = $Hook
@export var grapple_length: float = 200.0
@export var hook_speed = 1500.0

signal grapple_attached(hook_location: Vector2)  # global position
signal grapple_detached

var firing = false
var will_hook = false
var target_pos = Vector2.ZERO


func _process(delta):
	hook.visible = firing
	links.visible = firing
	if firing:
		var grapple_dir = to_local(target_pos).normalized()
		hook.position += grapple_dir * delta * hook_speed
		# If we've passed our target_pos.
		if grapple_dir.dot(hook.position - to_local(target_pos)) > 0.0:
			hook.position = to_local(target_pos)
			if not will_hook:
				firing = false
		_update_links_visual()


func _input(event: InputEvent) -> void:
	if InputMap.event_is_action(event, "grapple"):
		if event.pressed:
			if event is InputEventMouseButton:
				fire_grapple(get_local_mouse_position())
			elif event is InputEventJoypadButton:
				var target_position = Vector2(
					Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
				)
				# Apply a deadzone. Shoots up by default.
				if target_position.length() < 0.2:
					target_position = Vector2.UP

				fire_grapple(target_position)
		else:
			grapple_detached.emit()
			firing = false


func fire_grapple(target_position):
	raycast.target_position = target_position.normalized() * grapple_length
	raycast.force_raycast_update()

	firing = true
	will_hook = raycast.is_colliding()
	target_pos = to_global(raycast.target_position)
	hook.position = Vector2.ZERO
	_update_links_visual()
	links.visible = true
	hook.visible = true

	if raycast.is_colliding():
		grapple_attached.emit(raycast.get_collision_point())
		target_pos = raycast.get_collision_point()


# Creates the links from origin to hook location.
func _update_links_visual():
	links.rotation = position.angle_to_point(hook.position) - deg_to_rad(90)
	var node_scale_compensation = Vector2(1.0, 1.0) / links.scale
	links.region_rect.size.y = hook.position.length() * node_scale_compensation.y
	links.position = hook.position / 2.0
