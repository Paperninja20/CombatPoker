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


func _on_ConfirmRiverTurn_pressed():
	submit()
	
func submit():	
	var keeps = []
	var discards = []
	
	if get_parent().keep:
		keeps.append(get_parent().cardname)
	else:
		discards.append(get_parent().cardname)
	
	
	var myPlayer = Global.getMyPlayer()
	
	if Network.phase == "turn":
		
		for card in keeps:
			var cardInstance = load("res://Cards/" + card + ".tscn")
			var newCard = cardInstance.instance()
			newCard.position.x += 180 * myPlayer.find_node("Keeps").get_child_count()
			myPlayer.find_node("Keeps").add_child(newCard)
		for card in discards:
			var cardInstance = load("res://Cards/" + card + ".tscn")
			var newCard = cardInstance.instance()
			newCard.position.x += 180 * myPlayer.find_node("Discards").get_child_count()
			myPlayer.find_node("Discards").add_child(newCard)
			
		Network.sendTurnToServer(Network.self_data.name, keeps, discards)
		get_parent().softReset()
		
	elif Network.phase == "river":
		for card in keeps:
			var cardInstance = load("res://Cards/" + card + ".tscn")
			var newCard = cardInstance.instance()
			newCard.position.x += 180 * myPlayer.find_node("Keeps").get_child_count()
			myPlayer.find_node("Keeps").add_child(newCard)
		for card in discards:
			var cardInstance = load("res://Cards/" + card + ".tscn")
			var newCard = cardInstance.instance()
			newCard.position.x += 180 * myPlayer.find_node("Discards").get_child_count()
			myPlayer.find_node("Discards").add_child(newCard)
			
		Network.sendRiverToServer(Network.self_data.name, keeps, discards)
		get_parent().reset()
	var turnTimer = get_tree().get_root().get_node("Board").get_node("TurnTimer")
	turnTimer.stop()
	turnTimer.wait_time = Global.turnTimer
