extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var hovering = false

func _input(event):
	if event is InputEventMouseButton and hovering:
		if event.is_pressed():
			Network.sendCheck()
			if get_tree().is_network_server():
				Network.serverEndBet(true)
			else:
				Network.serverEndBet(false)
			get_parent().reset()
			set("custom_colors/font_color", Color("#ffffff"))
			hovering = false
			get_parent().get_parent().get_node("TurnTimer").reset()
			

func _on_Check_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true

func _on_Check_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
