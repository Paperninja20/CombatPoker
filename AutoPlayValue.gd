extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hovering

# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseButton and hovering:
		if event.is_pressed():
			if text == "ON":
				text = "OFF"
				Global.autoStart = false
			else:
				text = "ON"
				Global.autoStart = true


func _on_AutoPlayValue_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true


func _on_AutoPlayValue_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
