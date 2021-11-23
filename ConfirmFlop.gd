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


func _on_ConfirmFlop_pressed():
	submit()
	
func submit():
	var RiverTurnInfo = get_parent().get_parent().get_node("RiverTurn")
	var keeps = []
	var discards = []
	
	if get_parent().keep1:
		keeps.append(get_parent().flop1)
	else:
		discards.append(get_parent().flop1)
		
	if get_parent().keep2:
		keeps.append(get_parent().flop2)
	else:
		discards.append(get_parent().flop2)
	
	if get_parent().keep3:
		keeps.append(get_parent().flop3)
	else:
		discards.append(get_parent().flop3)
	
	RiverTurnInfo.currentlyDiscarding += discards.size()
	RiverTurnInfo.slotsAvailable -= keeps.size()
	
	Network.sendFlopToServer(Network.self_data.name, keeps, discards)
	get_parent().reset()

