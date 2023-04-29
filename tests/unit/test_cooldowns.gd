extends GutTest

# Seconds. This shouldn't go below the physics tick time. About 17ms for 60fps.
const ADD_WAIT_TIME = 0.4
# GUT used to be very flakey with its yield times. Perhaps it is working in
# Godot 4?
const WAIT_BUFFER = 0

var _cooldowns
var _callback_called


func _on_cooldown_no_arg():
	_callback_called = true


func _on_cooldown_arg(arg):
	assert_eq(arg, 123)
	_callback_called = true


func before_each():
	_callback_called = false
	_cooldowns = Cooldowns.new()
	add_child(_cooldowns)


func after_each():
	_cooldowns.free()


func test_add():
	_cooldowns.add("0", ADD_WAIT_TIME)
	assert_true(_cooldowns.exists("0"))
	assert_false(_cooldowns.exists("1"))

	await wait_seconds(ADD_WAIT_TIME / 2.0)
	assert_true(_cooldowns.exists("0"))

	await wait_seconds(ADD_WAIT_TIME / 2.0 + WAIT_BUFFER)
	assert_false(_cooldowns.exists("0"))


func test_remaining():
	_cooldowns.add("0", 2)
	assert_almost_eq(_cooldowns.remaining("0"), 2.0, 0.02)

	await wait_seconds(1)
	assert_almost_eq(_cooldowns.remaining("0"), 1.0, 0.2)
	await wait_seconds(1.2)
	assert_eq(_cooldowns.remaining("0"), 0.0)


func test_callback_no_arg():
	_cooldowns.add("0", ADD_WAIT_TIME, self, "_on_cooldown_no_arg")
	assert_false(_callback_called)
	await wait_seconds(ADD_WAIT_TIME + WAIT_BUFFER)
	assert_true(_callback_called)


func test_callback_arg():
	_cooldowns.add("0", ADD_WAIT_TIME, self, "_on_cooldown_arg", 123)
	assert_false(_callback_called)
	await wait_seconds(ADD_WAIT_TIME + WAIT_BUFFER)
	assert_true(_callback_called)


func test_remove():
	_cooldowns.add("0", ADD_WAIT_TIME, self, "_on_cooldown_no_arg")
	_cooldowns.remove("0")
	assert_true(_callback_called)
	assert_false(_cooldowns.exists("0"))


func test_remove_no_callback():
	_cooldowns.add("0", ADD_WAIT_TIME, self, "_on_cooldown_no_arg")
	_cooldowns.remove_no_callback("0")
	assert_false(_callback_called)
	assert_false(_cooldowns.exists("0"))


func test_cooldowns_spawner():
	# The spawner creates 1 child timer by default.
	assert_eq(_cooldowns.get_children().size(), 1)
	_cooldowns.add("0", ADD_WAIT_TIME)
	_cooldowns.add("1", ADD_WAIT_TIME)
	_cooldowns.add("2", ADD_WAIT_TIME)
	assert_eq(_cooldowns.get_children().size(), 3)

	await wait_seconds(ADD_WAIT_TIME + WAIT_BUFFER)
	assert_eq(_cooldowns.get_children().size(), 3)
	_cooldowns.add("3", ADD_WAIT_TIME)
	_cooldowns.add("4", ADD_WAIT_TIME)
	_cooldowns.add("5", ADD_WAIT_TIME)
	_cooldowns.add("6", ADD_WAIT_TIME)
	assert_eq(_cooldowns.get_children().size(), 4)
