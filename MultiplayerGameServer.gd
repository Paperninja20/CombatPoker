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
	mainPlayer.get_node("BettingPhase/Money").text = "$" + str(playerInfo.money)
	mainPlayer.get_node("BettingPhase/BetAmount").rect_scale = Vector2(0.65,0.65)
	mainPlayer.scale = Vector2(.9, .9)
	mainPlayer.position = Vector2(960, 920)
	get_tree().get_root().get_node("Board").add_child(mainPlayer)
	Network.playerOrder.append(mainPlayer)
	mainPlayer.add_to_group("Players")
	
	for entry in Global.deck:
		deck.append(entry)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_TextureButton_pressed():
	if Network.players.size() < 2:
		return
	get_node("TextureButton").visible = false
	startRound()

func startRound():
	Network.togglePots()
	Network.currentBet = Global.blindAmount
	Network.currentPot = 0
	Network.activePlayers = Network.playerOrder.duplicate(true)
	var rotatingPlayer = Network.activePlayers.pop_front()
	Network.activePlayers.append(rotatingPlayer)
	for participant in Network.activePlayers:
		participant.get_node("BettingPhase").visible = true
		participant.get_node("CombatPhase").visible = false
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
	
func battlePhase():
	Network.determineTargeting(Network.activePlayers)
	Network.playMinions()
	

