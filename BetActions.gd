extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func reset():
	$Raise.rect_position = Vector2(1217, 960)
	$Check.rect_position = Vector2(1377, 960)
	$Call.rect_position = Vector2(1567, 960)
	$Fold.rect_position = Vector2(1712, 960)
	$Raise.visible = true
	$Raise.get_node("RaiseAmount").visible = false
	$Raise.get_node("SubmitRaise").visible = false
	$Check.visible = true
	$Call.visible = true
	$Fold.visible = true
	visible = false
	
