class_name Cooldowns
extends Node

@onready var physics_tick_length = 1.0 / ProjectSettings.get_setting("physics/common/physics_fps")
var timers = []
var timer_to_cooldown = {}
var cooldown_to_timer = {}
var timer_to_callbacks = {}


# This resets the timer and overrides the callback if another of the same name
# is given.
# GDScript doesn't allow for array unpacking in function calls so
# we can not support more than one argument for the callback.
func add(name, duration, target = null, method = "", arg = null):
	var timer = _find_timer(name)

	timer_to_cooldown[timer] = name
	cooldown_to_timer[name] = timer
	timer_to_callbacks[timer] = []
	if target != null:
		timer_to_callbacks[timer].append([target, method, arg])
	timer.start(duration)


func frames_time(frames):
	# We still use timers.
	return frames * physics_tick_length - 0.002


func exists(name):
	return name in cooldown_to_timer


func remaining(name):
	if not name in cooldown_to_timer:
		return 0.0
	var timer = _find_timer(name)
	return timer.get_time_left()


func remove(name):
	var timer = _find_timer(name)
	_call_callbacks(timer)
	_release_timer(timer)


func remove_no_callback(name):
	var timer = _find_timer(name)
	_release_timer(timer)


func _ready():
	_spawnTimer()


func _on_Timer_timeout(timer):
	_call_callbacks(timer)
	_release_timer(timer)


func _call_callbacks(timer):
	for callback in timer_to_callbacks[timer]:
		if callback[2] != null:
			callback[0].call(callback[1], callback[2])
		else:
			callback[0].call(callback[1])


# Get either the existing timer or an available one.
func _find_timer(name):
	var timer = null
	if name in cooldown_to_timer:
		timer = cooldown_to_timer[name]
	else:
		for t in timers:
			if t.is_stopped():
				timer = t
				break
		if timer == null:
			timer = _spawnTimer()
	return timer


# This does not free the child node from the scene tree.
func _release_timer(timer):
	timer.stop()
	var cooldown = timer_to_cooldown[timer]
	if cooldown in cooldown_to_timer:
		cooldown_to_timer.erase(cooldown)
	timer_to_cooldown[timer] = null
	timer_to_callbacks[timer] = []


func _spawnTimer():
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	timer.connect("timeout", self, "_on_Timer_timeout", [timer])
	add_child(timer)
	timers.append(timer)
	timer_to_cooldown[timer] = null
	timer_to_callbacks[timer] = []
	return timer
