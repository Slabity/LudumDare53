extends Node2D

const Objectives = { ObjectiveTower = "Tower", ObjectiveDungeon =  "Dungeon", ObjectivePit = "Pit", ObjectiveOutskirts = "Outskirts", NoObjective = ""}

var player_is_in_quest_hub = false
var is_menu_visible = false
var current_objective = Objectives.NoObjective
var were_questing = false
var target = Vector2(0,0)
@onready var timer_node = get_node("../Camera2D/Timer")
signal quest_completed (time_completed_string: String)
signal target_set (target: Node)


func _physics_process(delta):
	if (player_is_in_quest_hub):
		if Input.is_action_just_released("Interact"):
			var node = get_child(5)
			if node != null:
				node.visible = true
				is_menu_visible = true
				
			node = get_child(0)
			if node != null:
				node.visible = false


func _on_quest_hub_area_body_entered(body):
		player_is_in_quest_hub = true
		var node = get_child(0)
		if node != null:
			node.visible = true
		
		

func _on_quest_hub_area_body_exited(body):
		player_is_in_quest_hub = false
		var node = get_child(0)
		if node != null:
			node.visible = false
		
		if(is_menu_visible):
			node = get_child(5)
			if node != null:
				node.visible = false
				is_menu_visible = false
				
				
		if (current_objective != Objectives.NoObjective):
			were_questing = true
			
			match  current_objective:
				Objectives.ObjectiveTower:
					node = get_child(4)
					if node != null:
						node.visible = true
						target = node.position
						target_set.emit(target)
						
				Objectives.ObjectiveDungeon:
					node = get_child(1)
					if node != null:
						node.visible = true
						target = node.position
						target_set.emit(target)
					
				Objectives.ObjectivePit:
					node = get_child(2)
					if node != null:
						node.visible = true
						target = node.position
						target_set.emit(target)
					
				Objectives.ObjectiveOutskirts:
					node = get_child(3)
					if node != null:
						node.visible = true
						target = node.position
						target_set.emit(target)


func _on_outskirts_button_pressed():
	current_objective = Objectives.ObjectiveOutskirts
	


func _on_dungon_button_pressed():
	current_objective = Objectives.ObjectiveDungeon


func _on_pit_button_pressed():
	current_objective = Objectives.ObjectivePit


func _on_tower_button_pressed():
	current_objective = Objectives.ObjectiveTower


func _on_dungeon_quest_objective_area_body_entered(body):
	if (body.is_in_group("Player") && current_objective == Objectives.ObjectiveDungeon):
		var node = get_child(1)
		if node != null:
			node.visible = false
			
		quest_completed.emit(timer_node.text)
		


func _on_pit_quest_objective_area_body_entered(body):
	if (body.is_in_group("Player") && current_objective == Objectives.ObjectivePit):
		var node = get_child(2)
		if node != null:
			node.visible = false
			
		quest_completed.emit(timer_node.text)
		


func _on_outskirts_quest_objective_area_body_entered(body):
	if (body.is_in_group("Player") && current_objective == Objectives.ObjectiveOutskirts):
		var node = get_child(3)
		if node != null:
			node.visible = false
			
		quest_completed.emit(timer_node.text)


func _on_tower_quest_objective_area_body_entered(body):
	if (body.is_in_group("Player") && current_objective == Objectives.ObjectiveTower):
		var node = get_child(4)
		if node != null:
			node.visible = false
			
		quest_completed.emit(timer_node.text)
