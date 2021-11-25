extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var hovering = false


func _input(event):
	if event is InputEventMouseButton and hovering:
		get_parent().reset()
		if event.is_pressed():
			submit()
			

func submit():
	get_parent().get_parent().get_node("TurnTimer").reset()
	get_parent().reset()
	Network.sendFold()
	if get_tree().is_network_server():
		Network.serverEndBet(true)
	else:
		Network.serverEndBet(false)
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
	
	
func _on_Fold_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true

func _on_Fold_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
