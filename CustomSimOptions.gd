extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.simulationMode = 1
	
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
	if Global.simulationMode == 1:
		get_tree().change_scene("res://Board.tscn")
	elif Global.simulationMode == 2:
		get_tree().change_scene("res://120Sim.tscn")


func _on_ModeArrow_pressed():
	if Global.simulationMode == 2:
		Global.simulationMode = 1
	else:
		Global.simulationMode += 1
	if Global.simulationMode == 1:
		$ModeArrow/ModeValue.text = "Step-through"
	elif Global.simulationMode == 2:
		$ModeArrow/ModeValue.text = "Optimal Line"
		
func _on_Back_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
