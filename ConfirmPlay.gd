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


func _on_ConfirmPlay_pressed():
	submit()
	
func submit():
	var myPlayer
	for player in get_tree().get_nodes_in_group("Players"):
		if player.name == Network.self_data.name:
			myPlayer = player
	var play = myPlayer.get_node("CombatPhase").get_node("Active").get_children()[0]
	var soundEffect = load("res://Assets/Sounds/" + play.idName + ".wav")
	if soundEffect:
		var soundPlayer = get_parent().get_node("MinionEffectPlayer")
		soundPlayer.stream = soundEffect
		#soundPlayer.play()
		
	
	Network.sendPlayToServer(Network.self_data.name, play.idName)
	visible = false
	var turnTimer = get_tree().get_root().get_node("Board").get_node("TurnTimer")
	turnTimer.reset()
