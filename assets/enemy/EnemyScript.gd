extends CharacterBody2D

var dir = true
var is_stealing = false
var can_steal = true
var stealing_speed_mod = 2
var dir_to_run_in_x = 0
var last_player_collision

const SPEED = 100.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var collision_tracker_array_left: Array = []
var collision_tracker_array_right: Array = []

var wall_collision_tracker_array_left: Array = []
var wall_collision_tracker_array_right: Array = []

signal asking_for_a_friend_do_you_have_treasure(thief: Node)
signal alright_you_got_me_have_your_stuff_back


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") && can_steal:
		last_player_collision = body.position
		asking_for_a_friend_do_you_have_treasure.emit(self)


func steal(has_treasure):
	#because I want it muahahahhahaha
	if has_treasure:
		var node = get_child(2)
		if node != null:
			node.visible = true

		node = get_child(3)
		if node != null:
			node.visible = true

		is_stealing = true
		if (last_player_collision - self.position).normalized().x > 0:
			dir_to_run_in_x = -1
		else:
			dir_to_run_in_x = 1


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_stealing:
		velocity.x = dir_to_run_in_x * SPEED * stealing_speed_mod
		move_and_slide()
		return

	if collision_tracker_array_right.size() == 0 && dir:
		dir = false

	if collision_tracker_array_left.size() == 0 && not dir:
		dir = true

	if wall_collision_tracker_array_right.size() != 0 && dir:
		dir = false

	if wall_collision_tracker_array_left.size() != 0 && not dir:
		dir = true

	if dir:
		velocity.x = SPEED
	else:
		velocity.x = -1 * SPEED

	move_and_slide()


func _on_floor_dector_right_body_exited(body):
	for i in range(collision_tracker_array_right.size()):
		if collision_tracker_array_right[i] == body:
			collision_tracker_array_right.remove_at(i)
			return


func _on_floor_dector_left_body_exited(body):
	for i in range(collision_tracker_array_left.size()):
		if collision_tracker_array_left[i] == body:
			collision_tracker_array_left.remove_at(i)
			return


func _on_floor_dector_left_body_entered(body):
	for i in range(collision_tracker_array_left.size()):
		if collision_tracker_array_left[i] == body:
			return

	collision_tracker_array_left.append(body)


func _on_floor_dector_right_body_entered(body):
	for i in range(collision_tracker_array_right.size()):
		if collision_tracker_array_right[i] == body:
			return

	collision_tracker_array_right.append(body)


func _on_wall_dector_right_body_entered(body):
	for i in range(wall_collision_tracker_array_right.size()):
		if wall_collision_tracker_array_right[i] == body:
			return

	wall_collision_tracker_array_right.append(body)


func _on_wall_dector_right_body_exited(body):
	for i in range(wall_collision_tracker_array_right.size()):
		if wall_collision_tracker_array_right[i] == body:
			wall_collision_tracker_array_right.remove_at(i)
			return


func _on_wall_dector_left_body_entered(body):
	for i in range(wall_collision_tracker_array_left.size()):
		if wall_collision_tracker_array_left[i] == body:
			return

	wall_collision_tracker_array_left.append(body)


func _on_wall_dector_left_body_exited(body):
	for i in range(wall_collision_tracker_array_left.size()):
		if wall_collision_tracker_array_left[i] == body:
			wall_collision_tracker_array_left.remove_at(i)
			return


func _on_stomp_detector_body_entered(body):
	if is_stealing:
		print("you got me")
		is_stealing = false

		var node = get_child(2)
		if node != null:
			node.visible = false

		node = get_child(3)
		if node != null:
			node.visible = false

		alright_you_got_me_have_your_stuff_back.emit()
		steal_cooldown()


func steal_cooldown():
	can_steal = false
	await get_tree().create_timer(10).timeout
	can_steal = true
