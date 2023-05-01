extends CharacterBody2D

var powers = [
	PlayerPower.GRAPPLE_KICK, PlayerPower.GRAPPLE, PlayerPower.DASH_KICK, PlayerPower.DASH
]

enum Cooldowns {
	DASH,
	DASH_LIMIT,
	DASH_EARLY,
	JUMP_RELEASE_ALLOWED,  # Time after jump
	COYOTE_JUMP,
	COYOTE_LEFT_WALL,
	COYOTE_RIGHT_WALL,
	COYOTE_DASH,
	WALL_DASH_RESET,
	WALL_KICK_ANIM,
	WALL_KICK_HARD,
	WALL_KICK_DASH_RESET,
	WALL_KICK_RECENT,
	HYPER,
	GRAPPLE_KICK,
}

@onready var gravity = ProjectSettings.get("physics/2d/default_gravity")
@onready var floor_detector = $FloorDetector
@onready var left_wall_detector = $LeftWallDetector
@onready var right_wall_detector = $RightWallDetector
@onready var animation_sprite = $AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D
@onready var cooldowns = $Cooldowns
@onready var grapple_node = $grapple_hook
@onready var dash_particles = $DashParticles
@onready var sound_jump = $SoundJump
@onready var sound_land = $SoundLand
@onready var sound_dash = $SoundDash

@export var air_momentum = 0.96  # Higher is more drag.
@export var air_input_multiplier = 0.75  # Input influence while in air
@export var dash_trail_sprite: PackedScene
@export var speed = Vector2(200.0, 350.0)
@export var dash_speed = Vector2(500.0, 500.0)  # Additive to pre-dash velocity
@export var dash_length = 0.2  # Duration of dash effect - how long we fast.
@export var dash_limit = 0.4  # Cooldown between dashes (unless other tech is used)
@export var dash_reset_early = 0.16
@export var dash_timed_reset = 2.0  # Time based dash reset.
@export var gravity_multiplier = 1.2
@export var gravity_input_control_up = 0.9
@export var gravity_input_control_down = 1.1
@export var wall_friction = 0.9
@export var wall_kick_speed = 300.0
@export var wall_hard_kick_speed = 1.3
@export var wall_hard_kick_influence = 1.5  # multipler on movement away from wall post kick.
@export var wall_bounce_speed = Vector2(4, 2)
@export var hyper_speed = 1.5
@export var hyper_speed_long = 350.0
@export var coyote_time = 0.1  # Coyote time: ability to jump after recently leaving the ground.
@export var grapple_kick_strength = 25.0
@export var grapple_kick_length = 0.2
@export var grapple_spring_const = 25.0
@export var grapple_damp_const = Vector2(1.0, 2.0)
@export var grapple_swing_ratio = 0.06  # How much the velocity influences the swing force.
@export var grapple_max_force = 18.0

var _has_dash_power = true
var _dash_dir = Vector2.ZERO
var _can_dash = true:
	set = set_can_dash
var _dash_trail_tick = false
var _pre_dash_velocity = Vector2.ZERO

var _wall_dir_kick_hard

var _was_on_floor = false
var _was_left_colliding = false
var _was_right_colliding = false
var _was_dashing = false

var tween
var _forced_movement = false
var _forced_start
var _forced_end
@export var _forced_threshold = 26

var grapple_hook_location = Vector2.ZERO


func _input(event):
	pass
	# if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
	# 	force_to(get_global_mouse_position())


func set_can_dash(val):
	if not _has_dash_power:
		_can_dash = false
	else:
		_can_dash = val


func remove_power(power):
	powers.erase(power)
	match power:
		PlayerPower.GRAPPLE_KICK:
			grapple_kick_strength = 0
			grapple_spring_const *= 0.5
			grapple_damp_const *= 2.0
		PlayerPower.GRAPPLE:
			grapple_node.enabled = false
		PlayerPower.DASH_KICK:
			hyper_speed = 0.5
			wall_bounce_speed = Vector2(1.0, 1.0)
		PlayerPower.DASH:
			_has_dash_power = false


# Forcibly move character to position.
func force_to(pos):
	_forced_movement = true
	_forced_start = position
	_forced_end = pos
	velocity = Vector2.ZERO
	tween = create_tween()
	# 2203 is diagonal pixels of 1080p. Linear movement time from 0.1 seconds to
	# 0.6 seconds.
	var movement_time = min(position.distance_to(pos) / 2203.0, 1.0) * 0.5 + 0.1
	(
		tween
		. tween_property(self, "position", pos, movement_time)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	# This callback won't naturally happen in most cases because of an early stop
	# based on _forced_threshold.
	tween.finished.connect(_on_force_to_finished)


func _on_force_to_finished():
	tween.stop()
	_forced_movement = false
	velocity = Vector2.ZERO


func _physics_process(delta):
	if _forced_movement:
		if _forced_end.distance_to(position) < _forced_threshold:
			# End the tween early to be more responsive.
			_on_force_to_finished()
	else:
		var input_dir = input_direction()
		if is_on_floor() and !_was_on_floor:
			sound_land.play()
		_apply_coyote()
		_apply_movement(input_dir, delta)
		_check_jump(input_dir)
		_check_dash(input_dir)
		_apply_grapple(delta)
		move_and_slide()

		if is_on_floor() and not cooldowns.exists(Cooldowns.DASH_LIMIT):
			_can_dash = true

		_update_animation(input_dir)


# Unnormalized input direction.
func input_direction():
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")


# Updates _was_* variables and adds coyote_* cooldowns.
func _apply_coyote():
	if _was_on_floor and !is_on_floor():
		cooldowns.add(Cooldowns.COYOTE_JUMP, coyote_time)
	_was_on_floor = is_on_floor()

	if _was_left_colliding and !left_wall_detector.is_colliding():
		cooldowns.add(Cooldowns.COYOTE_LEFT_WALL, coyote_time)
	_was_left_colliding = left_wall_detector.is_colliding()

	if _was_right_colliding and !right_wall_detector.is_colliding():
		cooldowns.add(Cooldowns.COYOTE_RIGHT_WALL, coyote_time)
	_was_right_colliding = right_wall_detector.is_colliding()

	if _was_dashing and not _dashing():
		cooldowns.add(Cooldowns.COYOTE_DASH, coyote_time * 0.5)
	_was_dashing = _dashing()


func _apply_movement(input_dir, delta):
	if _dashing():
		var sliding = velocity.normalized() != _dash_dir.normalized()
		# Undo the normalization from Input.get_vector.
		velocity = (
			_pre_dash_velocity
			+ (
				Vector2(
					1.0 if _dash_dir.x > 0 else -1.0 if _dash_dir.x < 0 else 0.0,
					1.0 if _dash_dir.y > 0 else -1.0 if _dash_dir.y < 0 else 0.0
				)
				* dash_speed
			)
		)
		if sliding:
			velocity *= 0.7
		return

	var spd = hyper_speed_long if cooldowns.exists(Cooldowns.HYPER) else speed.x
	if cooldowns.exists(Cooldowns.WALL_KICK_HARD) and _wall_dir_kick_hard * input_dir.x < 0:
		# More speed away from wall after recently kicking off one.
		spd *= wall_hard_kick_influence

	var multiplier = 0.85 if not is_on_floor() else 1.0
	var input_multiplier = air_input_multiplier if not is_on_floor() else 1.0
	var desired_x = lerpf(velocity.x, input_dir.x * spd * input_multiplier, 0.3)
	velocity.x += desired_x - velocity.x * multiplier

	var grav_multiplier = 1.0
	if input_dir.y > 0:
		grav_multiplier = gravity_input_control_down
	elif input_dir.y < 0:
		grav_multiplier = gravity_input_control_up
	velocity.y += gravity * gravity_multiplier * delta * grav_multiplier

	# Apply wall friction. If applying friction for a certain time, reset dash.
	if (
		velocity.y > 0
		and (
			input_dir.x > 0.0 and right_wall_detector.is_colliding()
			or input_dir.x < 0.0 and left_wall_detector.is_colliding()
		)
		and not cooldowns.exists(Cooldowns.WALL_KICK_RECENT)
	):
		velocity.y *= wall_friction
		if !_can_dash:
			if cooldowns.exists(Cooldowns.WALL_KICK_DASH_RESET):
				cooldowns.remove(Cooldowns.WALL_KICK_DASH_RESET)
			elif !cooldowns.exists(Cooldowns.WALL_DASH_RESET):
				cooldowns.add(Cooldowns.WALL_DASH_RESET, dash_limit, self, "_reset_dash")
	else:
		if cooldowns.exists(Cooldowns.WALL_DASH_RESET):
			cooldowns.remove_no_callback(Cooldowns.WALL_DASH_RESET)


func _reset_dash():
	_can_dash = true


func _dashing():
	return cooldowns.exists(Cooldowns.DASH)


# Returns whether a wall jump occurred.
func _check_wall_jump(input_dir):
	# Noteably no coyote time check.
	if is_on_floor():
		return false

	var wall_dir = 0
	if (
		left_wall_detector.is_colliding() and right_wall_detector.is_colliding()
		or (
			cooldowns.exists(Cooldowns.COYOTE_LEFT_WALL)
			and cooldowns.exists(Cooldowns.COYOTE_RIGHT_WALL)
		)
	):
		# When between two walls, listen to the direction of the sprite.
		wall_dir = 1 if sprite.flip_h else -1
	elif left_wall_detector.is_colliding() or cooldowns.exists(Cooldowns.COYOTE_LEFT_WALL):
		wall_dir = -1
	elif right_wall_detector.is_colliding() or cooldowns.exists(Cooldowns.COYOTE_RIGHT_WALL):
		wall_dir = 1

	if wall_dir == 0:
		return false

	velocity.y = -speed.y
	velocity.x = wall_kick_speed * -wall_dir

	sound_land.play()
	cooldowns.add(Cooldowns.WALL_KICK_RECENT, 0.1)
	if !_can_dash:
		cooldowns.add(Cooldowns.WALL_KICK_DASH_RESET, dash_limit, self, "_reset_dash")

	# Input is toward wall.
	if input_dir.x * wall_dir > 0:
		velocity.x *= wall_hard_kick_speed
		cooldowns.add(Cooldowns.WALL_KICK_HARD, 0.3)
		_wall_dir_kick_hard = wall_dir
		# Look away from the wall.
		cooldowns.add(Cooldowns.WALL_KICK_ANIM, 0.4)
		sprite.flip_h = wall_dir > 0

	if _dashing() or cooldowns.exists(Cooldowns.COYOTE_DASH):
		cooldowns.remove_no_callback(Cooldowns.WALL_KICK_DASH_RESET)
		if _dash_dir.y < 0:
			velocity.y *= wall_bounce_speed.y
		elif _dash_dir.y > 0:
			velocity.y *= -wall_bounce_speed.y * 0.6
		if !cooldowns.exists(Cooldowns.DASH_EARLY):
			_can_dash = true

	cooldowns.remove_no_callback(Cooldowns.DASH)
	return true


func _check_jump(input_dir):
	if Input.is_action_just_pressed("jump"):
		# We use the floor detector to allow for sideways dash hypers.
		# For the regular jump, the additional check shouldn't matter.
		if (
			floor_detector.is_colliding()
			or is_on_floor()
			or cooldowns.exists(Cooldowns.COYOTE_JUMP)
		):
			velocity.y = -speed.y
			if (_dashing() or cooldowns.exists(Cooldowns.COYOTE_DASH)) and _dash_dir.y >= 0:
				cooldowns.remove_no_callback(Cooldowns.DASH)
				velocity.x *= abs(input_dir.x * hyper_speed)
				cooldowns.add(Cooldowns.HYPER, 0.35)
				if !cooldowns.exists(Cooldowns.DASH_EARLY):
					_can_dash = true
			cooldowns.add(Cooldowns.JUMP_RELEASE_ALLOWED, 0.2)
			sound_jump.play()

		_check_wall_jump(input_dir)

	if Input.is_action_just_released("jump") and cooldowns.exists(Cooldowns.JUMP_RELEASE_ALLOWED):
		velocity.y *= 0.4


func _check_dash(input_dir):
	if Input.is_action_just_pressed("dash") and _can_dash and input_dir != Vector2.ZERO:
		_dash_dir = input_dir
		_can_dash = false
		_pre_dash_velocity = velocity
		cooldowns.add(Cooldowns.DASH, dash_length)
		cooldowns.add(Cooldowns.DASH_LIMIT, dash_limit)
		cooldowns.add(Cooldowns.DASH_EARLY, dash_reset_early)
		sound_dash.play()


func _apply_grapple(delta):
	if grapple_hook_location == Vector2.ZERO:
		return

	var grapple_vector = to_local(grapple_hook_location)
	var grapple_dir = grapple_vector.normalized()

	# Apply a magical kick force.
	if cooldowns.exists(Cooldowns.GRAPPLE_KICK):
		velocity += grapple_dir * grapple_kick_strength

	# Also apply a spring force.
	var spring_rest_loc = grapple_vector
	var force = spring_rest_loc * grapple_spring_const
	force -= grapple_damp_const * velocity
	velocity += force * delta

	# Convert some velocity into a swing velocity.
	var perpendicular = Vector2(grapple_dir.y, grapple_dir.x)
	# Calculate orientation of perpendicular
	if grapple_dir.x > 0:
		perpendicular.y *= -1
	else:
		perpendicular.x *= -1
	if velocity.y > 0:
		perpendicular *= -1

	var swing_force = grapple_swing_ratio * velocity.length() * perpendicular
	swing_force = swing_force.clamp(
		Vector2(-grapple_max_force, -grapple_max_force),
		Vector2(grapple_max_force, grapple_max_force)
	)
	velocity += swing_force


func _update_animation(input_dir):
	# Wall jumps briefly lock sprite direction.
	if input_dir.x != 0 and not cooldowns.exists(Cooldowns.WALL_KICK_ANIM):
		sprite.flip_h = not input_dir.x > 0

	var animation_new = ""
	if is_on_floor():
		if abs(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	else:
		if velocity.y > 0:
			animation_new = "falling"
		else:
			animation_new = "jump"
	animation_sprite.play(animation_new)

	if _dashing():
		if _dash_trail_tick:
			_dash_trail_tick = false
			var dash_node = dash_trail_sprite.instantiate()
			dash_node.global_position = sprite.global_position
			dash_node.flip_h = sprite.flip_h
			dash_node.frame = sprite.frame
			get_parent().add_child(dash_node)
			# Index 0 is background. Place these above the background.
			get_parent().move_child(dash_node, 1)
		else:
			_dash_trail_tick = true

	dash_particles.emitting = _dashing()
	# Disable or enable outline based on ability to dash.
	animation_sprite.material.set_shader_parameter(
		"line_color", Color(1, 0.58, 0.49, 0.68 if _can_dash else 0.0)
	)
	$DebugDot.visible = _can_dash


func _on_grapple_hook_grapple_detached():
	grapple_hook_location = Vector2.ZERO


func _on_grapple_hook_grapple_attached(hook_location: Vector2):
	_reset_dash()
	grapple_hook_location = hook_location
	cooldowns.add(Cooldowns.GRAPPLE_KICK, grapple_kick_length)
