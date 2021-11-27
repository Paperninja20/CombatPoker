extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var flop1
var flop2
var flop3
var tempflop


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

func swapHidden(newHidden, buttonName):
	tempflop = flop3
	flop3 = newHidden
	if flop1 == newHidden:
		flop1 = tempflop
	elif flop2 == newHidden:
		flop2 = tempflop
	elif flop3 == newHidden:
		flop3 = tempflop
	var button1 = find_node("RevealButton")
	var button2 = find_node("RevealButton2")
	var button3 = find_node("RevealButton3")
	
	match buttonName:
		"RevealButton":
			button2.disabled = false
			button3.disabled = false
		"RevealButton2":
			button1.disabled = false
			button3.disabled = false
		"RevealButton3":
			button2.disabled = false
			button1.disabled = false

func toggleRevealButtons(on):
	var button1 = find_node("RevealButton")
	var button2 = find_node("RevealButton2")
	var button3 = find_node("RevealButton3")
	
	if on:
		button1.visible = true
		button2.visible = true
		button3.visible = true
	else:
		button1.visible = false
		button2.visible = false
		button3.visible = false

		
		
		
		
