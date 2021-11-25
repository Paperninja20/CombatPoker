extends Timer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var turn = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	wait_time = Global.turnTimer
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(time_left)
	pass
	
	
func startPhase(phase):
	turn = phase
	start()

func _on_TurnTimer_timeout():
	match turn:
		"Betting":
			Network.sendFold()
			if get_tree().is_network_server():
				Network.serverEndBet(true)
			else:
				Network.serverEndBet(false)
			get_parent().get_node("BetActions").reset()
				
		"Mulling":
			if Network.phase == "flop":
				get_parent().get_node("FlopScreen").get_node("ConfirmFlop").submit()
			elif Network.phase == "turn" or Network.phase == "river":
				get_parent().get_node("RiverTurn").get_node("ConfirmRiverTurn").submit()
		"Playing":
			var myPlayer = Global.getMyPlayer()
			print(myPlayer.name, " turnTimer")
			myPlayer.playMinion()
			get_parent().get_node("ConfirmPlay").submit()

func reset():
	stop()
