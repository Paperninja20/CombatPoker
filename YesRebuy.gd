extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hovering

# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseButton and hovering:
		if event.is_pressed():
			visible = false
			get_parent().get_node("No").visible = false
			get_parent().get_node("MoneyField").visible = true
			get_parent().get_node("ConfirmRebuy").visible = true
			
func _on_Yes_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true

func _on_Yes_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
