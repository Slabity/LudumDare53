extends Node2D

const Objectives = {
	ObjectiveTower = 4,
	ObjectiveDungeon = 1,
	ObjectivePit =2,
	ObjectiveOutskirts = 3,
	NoObjective = 0

}


var BestTime = {
	Tower = 999999999999999999,
	Dungeon = 999999999999999999,
	Pit =999999999999999999,
	Outskirts = 999999999999999999,
}

@onready var sound_quest_complete = $QuestComplete
@onready var sound_quest_update = $QuestUpdate

var player_is_in_quest_hub = false
var is_menu_visible = false
var current_objective = Objectives.NoObjective
var were_questing = false
var target
var current_thief

@onready var map_node = get_node("..")
@onready var enemy_holder_node = get_node("../EnemyHolder")
signal quest_completed(time_completed_string: String, best_time_string: String)
signal target_set(target: Node)
signal quest_started()

func _ready():
	if(enemy_holder_node):
		for i in enemy_holder_node.get_child_count():
			var node = enemy_holder_node.get_child(i)
			node.connect("asking_for_a_friend_do_you_have_treasure", ProcessTheft)
			node.connect("alright_you_got_me_have_your_stuff_back", ProcessCounterTheft)

func _physics_process(delta):
	if player_is_in_quest_hub:
		if Input.is_action_just_released("Interact"):
			var node = get_child(5)
			if (set_node_visibility(5, true, false)):
				is_menu_visible = true
			
			set_node_visibility(0, false, false)
	
	

func ProcessTheft(thief):
	if(current_objective != Objectives.NoObjective && not current_thief):
		#........ I do have treasure why do you ask?
		thief.steal(true)
		target_set.emit(thief)
		sound_quest_update.play()
		current_thief = thief
		set_node_visibility(current_objective, false, false)

func ProcessCounterTheft():
	current_thief = null
	if(set_node_visibility(current_objective, true, true)):
			target_set.emit(target)
			sound_quest_update.play()
		

func _on_quest_hub_area_body_entered(body):
	player_is_in_quest_hub = true
	set_node_visibility(0, true, false)


func _on_quest_hub_area_body_exited(body):
	player_is_in_quest_hub = false
	var node = get_child(0)
	if node != null:
		node.visible = false
	if is_menu_visible:
		if(set_node_visibility(5, false, false)):
			is_menu_visible = false
	if current_objective != Objectives.NoObjective:
		were_questing = true
		quest_started.emit()
		if(set_node_visibility(current_objective, true, true)):
			target_set.emit(target)
			sound_quest_update.play()
			


func set_node_visibility(child_to_toggle: int, state_to_set: bool,set_current_target: bool):
	var node = get_child(child_to_toggle)
	if node != null:
		node.visible = state_to_set
		if(set_current_target):
			target = node
		return true
	
	return false
	

func _on_outskirts_button_pressed():
	current_objective = Objectives.ObjectiveOutskirts


func _on_dungon_button_pressed():
	current_objective = Objectives.ObjectiveDungeon


func _on_pit_button_pressed():
	current_objective = Objectives.ObjectivePit


func _on_tower_button_pressed():
	current_objective = Objectives.ObjectiveTower

func finish_quest(child_to_hide):
	if (not current_thief):
		current_objective = Objectives.NoObjective
		var node = get_child(child_to_hide)
		if node != null:
			node.visible = false
		
		var time = Time.get_unix_time_from_system()
		var delta = map_node.time_delta_unix
		var run_best_time = 0
		match(child_to_hide):
			Objectives.ObjectiveDungeon:
				if(BestTime.Dungeon > delta):
					BestTime.Dungeon = delta
				run_best_time =BestTime.Dungeon
			Objectives.ObjectiveOutskirts:
				if(BestTime.Outskirts > delta):
					BestTime.Outskirts = delta
				run_best_time =BestTime.Outskirts
			Objectives.ObjectivePit:
				if(BestTime.Pit > delta):
					BestTime.Pit = delta
				run_best_time =BestTime.Pit
			Objectives.ObjectiveTower:
				if(BestTime.Tower > delta):
					BestTime.Tower = delta
				run_best_time =BestTime.Tower
		
		quest_completed.emit(map_node.time_delta + ":%02d" % int(fmod(time, 1) * 100), run_best_time)
		sound_quest_complete.play()

func _on_dungeon_quest_objective_area_body_entered(body):
	if body.is_in_group("Player") && current_objective == Objectives.ObjectiveDungeon:
		finish_quest(1)


func _on_pit_quest_objective_area_body_entered(body):
	if body.is_in_group("Player") && current_objective == Objectives.ObjectivePit:
		finish_quest(2)



func _on_outskirts_quest_objective_area_body_entered(body):
	if body.is_in_group("Player") && current_objective == Objectives.ObjectiveOutskirts:
		finish_quest(3)
		


func _on_tower_quest_objective_area_body_entered(body):
	if body.is_in_group("Player") && current_objective == Objectives.ObjectiveTower:
		finish_quest(4)

