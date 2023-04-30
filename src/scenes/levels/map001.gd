extends Node2D

@onready var timer_label = $Camera2D/Timer

var started = false
var start_time
var completion_time


func _process(_delta):
	if started:
		var time = Time.get_unix_time_from_system()
		var time_delta = Time.get_time_string_from_unix_time(time - start_time)
		timer_label.text = time_delta + ":%02d" % int(fmod(time, 1) * 100)


func _on_start_area_body_entered(_body: Node2D):
	if !started:
		started = true
		start_time = Time.get_unix_time_from_system()


func _on_win_area_body_entered(_body: Node2D):
	if started:
		started = false
		completion_time = Time.get_unix_time_from_system()
