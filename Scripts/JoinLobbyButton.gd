extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hovering = false

func _input(event):
	if event is InputEventMouseButton and hovering:
		if event.is_pressed():
			print(get_parent().get_node("NicknameField").text)
			Network.JoinLobby(get_parent().get_node("NicknameField").text, int(get_parent().get_node("MoneyField").text))
			get_tree().change_scene("res://MultiplayerGame.tscn")
			hovering = false
			set("custom_colors/font_color", Color("#c9a17e"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_JoinLobby_mouse_entered():
	set("custom_colors/font_color", Color("#848384"))
	hovering = true


func _on_JoinLobby_mouse_exited():
	set("custom_colors/font_color", Color("#ffffff"))
	hovering = false
