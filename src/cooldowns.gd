class_name Cooldowns
extends Node

var timers = []
var timer_to_cooldown = {}
var cooldown_to_timer = {}
var timer_to_callbacks = {}


# This resets the timer and overrides the callback if another of the same name
# is given.
# GDScript doesn't allow for array unpacking in function calls so
# we can not support more than one argument for the callback.
func add(cd_name, duration, target = null, method = "", arg = null):
	var timer = _find_timer(cd_name)

	timer_to_cooldown[timer] = cd_name
	cooldown_to_timer[cd_name] = timer
	timer_to_callbacks[timer] = []
	if target != null:
		timer_to_callbacks[timer].append([target, method, arg])
	timer.start(duration)


func exists(cd_name):
	return cd_name in cooldown_to_timer


func remaining(cd_name):
	if not cd_name in cooldown_to_timer:
		return 0.0
	var timer = _find_timer(cd_name)
	return timer.get_time_left()


func remove(cd_name):
	var timer = _find_timer(cd_name)
	_call_callbacks(timer)
	_release_timer(timer)


func remove_no_callback(cd_name):
	var timer = _find_timer(cd_name)
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
func _find_timer(cd_name):
	var timer = null
	if cd_name in cooldown_to_timer:
		timer = cooldown_to_timer[cd_name]
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
	timer.set_timer_process_callback(Timer.TIMER_PROCESS_PHYSICS)
	timer.timeout.connect(_on_Timer_timeout.bind(timer))
	add_child(timer)
	timers.append(timer)
	timer_to_cooldown[timer] = null
	timer_to_callbacks[timer] = []
	return timer
