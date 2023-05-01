extends Node2D

@onready var timer_label = $Camera2D/Timer

var started = false
var start_time
var completion_time
var time_delta
var time_delta_unix


func _ready():
	timer_label.text = ""


func _process(_delta):
	if started:
		var time = Time.get_unix_time_from_system()
		time_delta_unix = time - start_time
		time_delta = Time.get_time_string_from_unix_time(time_delta_unix)
		timer_label.text = time_delta + ":%02d" % int(fmod(time, 1) * 100)


func _on_quest_system_quest_completed(time_completed_string, best_time):
	if started:
		started = false
		timer_label.text = ""
		completion_time = Time.get_unix_time_from_system()


func _on_quest_system_quest_started():
	started = true
	start_time = Time.get_unix_time_from_system()
