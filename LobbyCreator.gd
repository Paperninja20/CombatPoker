extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$NicknameField.text = Global.username
	$MoneyField.text = Global.money
	$IPField.text = Global.ip
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Back_pressed():
	Global.username = $NicknameField.text
	Global.money = $MoneyField.text
	Global.ip = $IPField.text
	get_tree().change_scene("res://MainMenu.tscn")
