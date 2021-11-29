extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cardname
var keep = true
var currentlyDiscarding = 0
var slotsAvailable = 3 setget setSlotsAvailable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func reset():
	keep = true
	$Card/X.visible = false
	currentlyDiscarding = 0
	slotsAvailable = 3
	visible = false
	for node in $Card.get_children():
		if not node is Sprite and not node is TextureButton:
			node.queue_free()
			
func softReset():
	if slotsAvailable > 0:
		$Card/X.visible = false
		keep = true
	visible = false
	for node in $Card.get_children():
		if not node is Sprite and not node is TextureButton:
			node.queue_free()
			
func setSlotsAvailable(newNum):
	if newNum == 0:
		$Card/X.visible = true
		keep = false
	slotsAvailable = newNum


func _on_RiverTurn_visibility_changed():
	var myPlayer = Global.getMyPlayer()
	if visible:
		currentlyDiscarding = myPlayer.find_node("Discards").get_child_count()
		slotsAvailable = 5 - myPlayer.find_node("Keeps").get_child_count()
		
