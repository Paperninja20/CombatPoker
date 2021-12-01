extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var deck = []

var player = preload("res://MultiplayerPlayer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var mainPlayer = player.instance()
	var playerInfo = Network.self_data
	mainPlayer.name = playerInfo.name
	mainPlayer.id = playerInfo.id
	mainPlayer.set_network_master(playerInfo.id, true)
	mainPlayer.get_node("PlayerTag").text = playerInfo.name
	mainPlayer.get_node("BettingPhase/Money").text = str(playerInfo.money)
	mainPlayer.get_node("BettingPhase/BetAmount").rect_scale = Vector2(0.83,0.83)
	mainPlayer.get_node("BettingPhase/BetAmount").rect_position.y += 6.29 
	mainPlayer.get_node("BettingPhase/BetAmount").rect_position.x += 15.81
	mainPlayer.get_node("BettingPhase/Capsule").scale *= .83
	mainPlayer.scale = Vector2(.9, .9)
	mainPlayer.position = Vector2(960, 920)
	mainPlayer.seat = 1
	get_tree().get_root().get_node("Board").add_child(mainPlayer)
	Network.playerOrder.append(mainPlayer)
	Network.allPlayers.append(mainPlayer)
	mainPlayer.add_to_group("Players")
	
	for entry in Global.deck:
		deck.append(entry)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_TextureButton_pressed():
	if Network.players.size() < 2:
		return
	if Network.playerOrder.size() < 2:
		return
	get_node("Start").visible = false
	startRound()

func startRound():
	randomize()
	Global.deck = deck.duplicate(true)
	Global.deck.shuffle()
	Network.togglePots(true)
	var rotatingPlayer = Network.playerOrder.pop_front()
	Network.playerOrder.append(rotatingPlayer)
	Network.rotations += 1
	Network.rotations %= Network.playerOrder.size()
	Network.activePlayers = Network.playerOrder.duplicate(true)
	for participant in Network.activePlayers:
		participant.get_node("BettingPhase").visible = true
		participant.get_node("CombatPhase").visible = false
	Network.sendTransition()
	yield(Network, "transitionOver")
	Network.sendPreflop()
	
	#set and call blinds
	var big = Network.activePlayers[1]
	var small = Network.activePlayers[0]
	
	Network.callBlinds(big, small)
	betting()
	
func betting():
	Network.sendBetActions()
	
func flop():
	Network.sendFlop()
	
#func battlePhase():
#	Network.determineTargeting(Network.activePlayers)
#	while not Network.gameOver:
#		print("Calling play minions")
#		Network.playMinions()
#		yield(Network, "attackPhase")
#		Network.attackPhase()
#		yield(Network, "playPhase")
#		print("received playphase signal")
#	endCurrentRound()

func playMinionsPhase():
	if not Network.gameOver:
		print("Calling play minions")
		Network.playMinions()
	else:
		endCurrentRound()

func attackPhase():
	print("Calling attack phase")
	Network.attackPhase()
	
func endCurrentRound():
	Network.distributeMoney()
	Network.kickPlayers()
	if Global.autoStart:
		restart()
	else:
		Network.resetAllPlayers()
		Network.resetValues()
		Network.togglePots(false)
		var myPlayer = Global.getMyPlayer()
		if myPlayer in Network.playerOrder:
			get_node("Start").visible = true

func restart():
	Network.resetAllPlayers()
	Network.resetValues()
	startRound()
