extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var originalPosition
var hovering
var magnified

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("Area2D").visible = false
	get_parent().hovering = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Hand_Button_pressed():
	if not Network.clickableHand:
		return
		
	var parentName = get_parent().get_parent().name
	var card = get_parent()
	
	if parentName == "Hand":
		var active = get_parent().get_parent().get_parent().get_node("Active")
		if active.get_child_count() > 0:
			return
		originalPosition = card.position
		card.position = Vector2(0,0)
		if card.has_method("preview"):
			card.preview(true)
		Global.reparent(card, "Active")
		get_tree().get_root().get_node("Board").get_node("ConfirmPlay").visible = true
	elif parentName == "Active":
		card.position = originalPosition
		if card.has_method("preview"):
			card.preview(false)
		Global.reparent(card, "Hand")
		get_tree().get_root().get_node("Board").get_node("ConfirmPlay").visible = false
	else:
		return


func _on_Hand_Button_mouse_entered():
	hovering = true
	if Global.altDown and not magnified:
		Global.magnify(get_parent())
		magnified = get_parent().magnified


func _on_Hand_Button_mouse_exited():
	hovering = false
#	if magnified:
#		Global.demagnify(get_parent(), Vector2(1,1))
#		magnified = false

func _input(event):
	if event.is_action_pressed("Alt"):
		if hovering:
			Global.magnify(get_parent())	
			magnified = get_parent().magnified
	if event.is_action_released("Alt"):
		if magnified:
			Global.demagnify(get_parent(), Vector2(1,1))
			magnified = get_parent().magnified
		
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		pass
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		if magnified:
			Global.demagnify(get_parent(), Vector2(1,1))
			magnified = get_parent().magnified
