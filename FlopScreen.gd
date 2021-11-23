extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var flop1
var flop2
var flop3

var keep1 = true
var keep2 = true
var keep3 = true

var currentlyDiscarding = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset():
	keep1 = true
	keep2 = true
	keep3 = true
	currentlyDiscarding = 0
	$Flop1/X.visible = false
	$Flop2/X.visible = false
	$Flop3/X.visible = false
	visible = false
	for node in $Flop1.get_children():
		if not node is Sprite and not node is TextureButton:
			node.queue_free()
	for node in $Flop2.get_children():
		if not node is Sprite and not node is TextureButton:
			node.queue_free()
	for node in $Flop3.get_children():
		if not node is Sprite and not node is TextureButton:
			node.queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
