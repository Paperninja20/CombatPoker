extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hovering = false

# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseButton and hovering:
		if event.is_pressed():
			Global.username = get_parent().get_node("NicknameField").text
			Global.money = get_parent().get_node("MoneyField").text
			Global.ip = get_parent().get_node("IPField").text
			get_tree().change_scene("res://MultiplayerOptions.tscn")
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Options_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true


func _on_Options_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
