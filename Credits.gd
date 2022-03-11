extends Label

var hovering = false

# Called when the node enters the scene tree for the first time.
#func _input(event):
	#if event is InputEventMouseButton and hovering:
		#if event.is_pressed():
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Custom_Simulation_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true

func _on_Custom_Simulation_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
