extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.playerCount > 2:
		$P3.visible = true
	if Global.playerCount > 3:
		$P4.visible = true
		
	var playerLabel
	playerLabel = $P1
	var index = 1
	for card in Global.P1Hand:
		playerLabel.get_node(str(index)).texture = load("res://Assets/CardAssets/" + card + ".png")
		index += 1
	
	playerLabel = $P2
	index = 1
	for card in Global.P2Hand:
		playerLabel.get_node(str(index)).texture = load("res://Assets/CardAssets/" + card + ".png")
		index += 1
		
	playerLabel = $P3
	index = 1
	for card in Global.P3Hand:
		playerLabel.get_node(str(index)).texture = load("res://Assets/CardAssets/" + card + ".png")
		index += 1
	
	playerLabel = $P4
	index = 1
	for card in Global.P4Hand:
		playerLabel.get_node(str(index)).texture = load("res://Assets/CardAssets/" + card + ".png")
		index += 1
		
func _on_Continue_pressed():
	get_tree().change_scene("res://Board.tscn")
