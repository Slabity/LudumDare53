extends Camera2D

@export var lerp_speed = 0.05
@export var target_node_path: NodePath

var target_node
var quest_target_node
var viewport: Rect2


func _ready():
	if target_node_path:
		target_node = get_node(target_node_path)


func _process(delta):
	if target_node:
		position = lerp(position, target_node.global_position, lerp_speed)

	if quest_target_node:
		var center = target_node.global_position
		var distance = center.distance_to(quest_target_node.position)
		if distance > 300:
			viewport = get_viewport_rect()

			# target vector
			var to_target_vector_normalized = (quest_target_node.position - center).normalized()

			var y = to_target_vector_normalized.y * abs(viewport.size.y / 4)
			var x = to_target_vector_normalized.x * abs(viewport.size.x / 4)
			var newv = Vector2(x, y)

			var node = get_child(3)
			if node != null:
				node.visible = true
				node.position = newv
		else:
			var node = get_child(3)
			if node != null:
				node.visible = false


func _on_quest_system_quest_completed(time_completed, best_time):
	quest_target_node = null
	var timernode = get_child(1)
	timernode.visible = true
	timernode.text = "Delivery Complete! Final Time: " + time_completed
	
	
	var bestnode = get_child(2)
	bestnode.visible = true
	bestnode.text = "Best Time: " + str(Time.get_time_string_from_unix_time(best_time))
	
	await get_tree().create_timer(3).timeout
	timernode.visible = false
	bestnode.visible = false


func _on_quest_system_target_set(target):
	quest_target_node = target

