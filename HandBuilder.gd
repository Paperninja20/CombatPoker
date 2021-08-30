extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hand
# Called when the node enters the scene tree for the first time.
func _ready():
	match Global.HandBuilding:
		1:
			hand = Global.P1Hand
		2:
			hand = Global.P2Hand
		3:
			hand = Global.P3Hand
		4:
			hand = Global.P4Hand
	
	var index = 1
	for card in hand:
		get_node(str(index)).texture = load("res://Assets/CardAssets/" + card + ".png")
		index += 1
			
	$PlayerHeader.text = "P" + str(Global.HandBuilding) + " HAND"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_Back_pressed():
	if hand.size() == 0:
		return
	get_node(str(hand.size())).texture = null
	hand.pop_back()


func _on_Done_pressed():
	match Global.HandBuilding:
		1:
			Global.P1Hand = hand
		2:
			Global.P2Hand = hand
		3:
			Global.P3Hand = hand
		4:
			Global.P4Hand = hand
	get_tree().change_scene("res://CustomSimOptions.tscn")
			

