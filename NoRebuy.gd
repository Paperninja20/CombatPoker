extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hovering

func _input(event):
	if event is InputEventMouseButton and hovering:
		if event.is_pressed():
			Network.kickSelf()
			get_tree().change_scene("res://LobbyCreator.tscn")
			

func _on_No_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true

func _on_No_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
