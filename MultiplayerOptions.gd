extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$TurnTimeInput.text = str(Global.turnTimer)
	$BlindAmountInput.text = str(Global.blindAmount)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Back_pressed():
	Global.turnTimer = int($TurnTimeInput.text)
	Global.blindAmount = int($BlindAmountInput.text)
	get_tree().change_scene("res://LobbyCreator.tscn")

