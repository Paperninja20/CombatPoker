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
	pass
	
	
func startPhase(phase):
	#print("starting for", get_tree().get_network_unique_id())
	turn = phase
	yield(get_tree().create_timer(0.05), "timeout")
	start()
#	for i in range(0, 1000):
#		print(time_left, " should be going")

func _on_TurnTimer_timeout():
	match turn:
		"Betting":
			get_parent().get_node("BetActions").get_node("Fold").submit()
				
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
