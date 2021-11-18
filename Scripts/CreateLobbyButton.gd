extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hovering = false

func _input(event):
	if event is InputEventMouseButton and hovering:
		if event.is_pressed():
			print(get_parent().get_node("NicknameField").text)
			Network.CreateLobby(get_parent().get_node("NicknameField").text)
			get_tree().change_scene("res://MultiplayerGameServer.tscn")
			hovering = false
			set("custom_colors/font_color", Color("#c9a17e"))


func _on_CreateLobby_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true


func _on_CreateLobby_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
