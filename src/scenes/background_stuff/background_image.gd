extends Node2D
var current_background
var last_background
var cur_background_string
var new_background

# Called when the node enters the scene tree for the first time.
func _ready():
	current_background = get_node("background_image_city")
	cur_background_string = "city"
	last_background = get_node("background_image_dungeon")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#make new background 100 visable, unless it's already visable
	if(!current_background.is_visible()):
		current_background.set_visible(true)
	#continue to fade the last background value unless it's already invisable
	if(last_background.is_visible()):
		last_background.set_visible(false)
#Takes a new new_background object. New Background should be a 2D sprite node?
#Or maybe a name? I may need to think about this a bit more.
func _set_background(_body,background_string):
	if(background_string != cur_background_string):
		cur_background_string = background_string
		new_background = get_node("background_image_"+background_string)
		last_background = current_background
		current_background = new_background
	
