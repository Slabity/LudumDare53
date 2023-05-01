extends Camera2D

@export var lerp_speed = 0.05
@export var target_node_path: NodePath

var target_node
var quest_target_node
var viewport : Rect2

func _ready():
	if target_node_path:
		target_node = get_node(target_node_path)
	
	

func _process(delta):
	if target_node:
		position = lerp(position, target_node.global_position, lerp_speed)
		
	if quest_target_node:
		var center = target_node.global_position
		var distance = center.distance_to(quest_target_node)
		if (distance > 300):
			viewport = get_viewport_rect()
			
			
			# target vector
			var to_target_vector_normalized =  (quest_target_node - center).normalized() 
			
			var y = to_target_vector_normalized.y  * abs(viewport.size.y /4)
			var x = to_target_vector_normalized.x * abs(viewport.size.x /4)
			var newv = Vector2(x, y)
			
			
			var node = get_child(2)
			if node != null:
				node.visible = true
				node.position = newv
		else:
			var node = get_child(2)
			if node != null:
				node.visible = false


func _on_quest_system_quest_completed(time_completed):
	quest_target_node = null
	var node = get_child(1)
	if node != null:
		node.visible = true
		node.text = "You did it! Final Time: " + time_completed
		await get_tree().create_timer(3).timeout
		node.visible = false


func _on_quest_system_target_set(target):
	quest_target_node = target
	
	
	
"""
Finds the intersection point between
the rectangle
with parallel sides to the x and y axes 
the half-line pointing towards (x,y)
originating from the middle of the rectangle

Note: the function works given min[XY] <= max[XY],
	  even though minY may not be the "top" of the rectangle
	  because the coordinate system is flipped.
Note: if the input is inside the rectangle,
	  the line segment wouldn't have an intersection with the rectangle,
	  but the projected half-line does.
Warning: passing in the middle of the rectangle will return the midpoint itself
		 there are infinitely many half-lines projected in all directions,
		 so let's just shortcut to midpoint (GIGO).

@param x:Number x coordinate of point to build the half-line from
@param y:Number y coordinate of point to build the half-line from
@param minX:Number the "left" side of the rectangle
@param minY:Number the "top" side of the rectangle
@param maxX:Number the "right" side of the rectangle
@param maxY:Number the "bottom" side of the rectangle
@param validate:boolean (optional) whether to treat point inside the rect as error
@return an object with x and y members for the intersection
@throws if validate == true and (x,y) is inside the rectangle
@author TWiStErRob
@licence Dual CC0/WTFPL/Unlicence, whatever floats your boat
@see <a href="http://stackoverflow.com/a/31254199/253468">source</a>
@see <a href="http://stackoverflow.com/a/18292964/253468">based on</a>
"""	
	
func pointOnRect(x, y, minX, minY, maxX, maxY):
	#assert minX <= maxX;
	#assert minY <= maxY;
	
	var midX = (minX + maxX) / 2;
	var midY = (minY + maxY) / 2;
	# if (midX - x == 0) -> m == ±Inf -> minYx/maxYx == x (because value / ±Inf = ±0)
	var m = (midY - y) / (midX - x);

	if (x <= midX) : # check "left" side
		var minXy = m * (minX - x) + y;
		if (minY <= minXy && minXy <= maxY):
			return Vector2(minX, minXy)

	if (x >= midX):  # check "right" side
		var maxXy = m * (maxX - x) + y;
		if (minY <= maxXy && maxXy <= maxY):
			return Vector2(maxX, maxXy)

	if (y <= midY): # check "top" side
		var minYx = (minY - y) / m + x;
		if (minX <= minYx && minYx <= maxX):
			return Vector2(minYx, minY)
	

	if (y >= midY) : # check "bottom" side
		var maxYx = (maxY - y) / m + x;
		if (minX <= maxYx && maxYx <= maxX):
			return Vector2(maxYx, maxY)
	

	# edge case when finding midpoint intersection: m = 0/0 = NaN
	if (x == midX && y == midY):
		return Vector2(x, y)

	
