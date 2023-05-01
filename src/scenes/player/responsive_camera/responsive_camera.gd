extends Camera2D

@export var lerp_speed = 0.05
@export var target_node_path: NodePath

var target_node


func _ready():
	if target_node_path:
		target_node = get_node(target_node_path)


func _process(delta):
	if target_node:
		position = lerp(position, target_node.global_position, lerp_speed)


func _on_quest_system_quest_completed(time_completed):
	var node = get_child(1)
	if node != null:
		node.visible = true
		node.text = "You did it! Final Time: " + time_completed
		await get_tree().create_timer(3).timeout
		node.visible = false
