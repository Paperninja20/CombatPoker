extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset():
	for child in $Keeps.get_children():
		$Keeps.remove_child(child)
		child.queue_free()
	for child in $Discards.get_children():
		$Discards.remove_child(child)
		child.queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
