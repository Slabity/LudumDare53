extends Sprite2D
var rotateValue


# Called when the node enters the scene tree for the first time.
func _ready():
	rotateValue = .01
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(rotateValue)
	if rotation > -.3:
		rotateValue = rotateValue * -1
	if rotation < .3:
		rotateValue = rotateValue * -1
	pass
