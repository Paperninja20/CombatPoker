extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Select_pressed():
	var flopData = get_parent().get_parent()
		
	var flopNumber = get_parent().get_name()

	
	var XNode = get_parent().get_node("X")
	if XNode.visible:
		XNode.visible = false
		flopData.currentlyDiscarding -= 1
		if flopData.currentlyDiscarding == 0:
			flopData.toggleRevealButtons(true)
	else:
		if flopData.currentlyDiscarding == 2:
			return
		XNode.visible = true
		flopData.toggleRevealButtons(false)
		flopData.currentlyDiscarding += 1
		
	
	match flopNumber:
		"Flop1":
			if flopData.keep1:
				flopData.keep1 = false
			else:
				flopData.keep1 = true
		"Flop2":
			if flopData.keep2:
				flopData.keep2 = false
			else:
				flopData.keep2 = true
		"Flop3":
			if flopData.keep3:
				flopData.keep3 = false
			else:
				flopData.keep3 = true
			
	

		

