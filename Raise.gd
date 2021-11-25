extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var hovering = false
# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseButton and hovering:
		get_parent().reset()
		if event.is_pressed():
			set("custom_colors/font_color", Color("#ffffff"))
			for node in get_children():
				if node.visible:
					node.visible = false
				else:
					node.visible = true
			if Network.currentBet != 0:
				$RaiseAmount.text = str(Network.currentBet * 2)
			else:
				$RaiseAmount.text = str(Global.blindAmount)

func _on_Raise_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true


func _on_Raise_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
