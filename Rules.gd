extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var nothing = 0
		
func _on_Back_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
