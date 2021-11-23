extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hovering = false

# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseButton and hovering:
		if event.is_pressed():
			get_tree().change_scene("res://CollectData.tscn")
			hovering = false
			set("custom_colors/font_color", Color("#ffffff"))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_CollectData_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true

func _on_CollectData_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
