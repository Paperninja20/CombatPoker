extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var myUser

# Called when the node enters the scene tree for the first time.
func _ready():
	myUser = Network.self_data.name
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SubmitRaise_pressed():
	var raiseAmount = int(get_parent().get_node("RaiseAmount").text)
	
	if raiseAmount < Network.currentBet * 2 or raiseAmount < 1:
		get_parent().get_node("RaiseAmount").text = "Too Low!"
		get_parent().get_node("RaiseAmount").editable = false
		yield(get_tree().create_timer(0.5), "timeout")
		if Network.currentBet != 0:
			get_parent().get_node("RaiseAmount").text = str(Network.currentBet * 2)
		else:
			get_parent().get_node("RaiseAmount").text = str(1)
		get_parent().get_node("RaiseAmount").editable = true
		return

	var myPlayer = get_parent().get_parent().get_parent().get_node(myUser)
	var totalMoney = Network.self_data.money + int(myPlayer.find_node("BetAmount").text)
	
	if raiseAmount > totalMoney:
		get_parent().get_node("RaiseAmount").text = "Too High!"
		get_parent().get_node("RaiseAmount").editable = false
		yield(get_tree().create_timer(0.5), "timeout")
		get_parent().get_node("RaiseAmount").text = str(Network.currentBet * 2)
		get_parent().get_node("RaiseAmount").editable = true
		return
		
	get_parent().get_parent().reset()
	get_parent().get_parent().get_parent().get_node("TurnTimer").reset()
	Network.sendRaise(raiseAmount)
	if get_tree().is_network_server():
		Network.serverEndBet(true)
	else:
		Network.serverEndBet(false)
