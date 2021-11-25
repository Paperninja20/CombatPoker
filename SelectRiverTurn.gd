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
	var RiverTurnData = get_parent().get_parent()
	
	var XNode = get_parent().get_node("X")
	if XNode.visible:
		if RiverTurnData.slotsAvailable <= 0:
			return
		XNode.visible = false
		#RiverTurnData.currentlyDiscarding -= 1
		#RiverTurnData.slotsAvailable -= 1
	else:
		if RiverTurnData.currentlyDiscarding == 2:
			return
		XNode.visible = true
		#RiverTurnData.currentlyDiscarding += 1
		#RiverTurnData.slotsAvailable += 1
		
		
	if RiverTurnData.keep:
		RiverTurnData.keep = false
	else:
		RiverTurnData.keep = true

