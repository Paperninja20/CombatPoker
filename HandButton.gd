extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var originalPosition

# Called when the node enters the scene tree for the first time.
func _ready():
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
		Global.reparent(card, "Active")
		get_tree().get_root().get_node("Board").get_node("ConfirmPlay").visible = true
	elif parentName == "Active":
		card.position = originalPosition
		Global.reparent(card, "Hand")
		get_tree().get_root().get_node("Board").get_node("ConfirmPlay").visible = false
	else:
		return
