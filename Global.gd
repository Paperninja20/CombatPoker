extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var playerCount = 2

var classes = ["Marvel", "Pokemon", "Star Wars", "Team Fortress", "Rodent"]

var cards = {
	"AntMan" : ["Marvel", 4],
	"TheHulk" : ["Marvel", 4],
	"Dormammu" : ["Marvel", 3],
	"NickFury" : ["Marvel", 3],
	"JeanGrey" : ["Marvel", 2],
	"CaptainAmerica" : ["Marvel", 1],
	"RocketRaccoon" : ["Marvel", 4],
	"Snorlax" : ["Pokemon", 4],
	"Exeggutor" : ["Pokemon", 4],
	"Lucario" : ["Pokemon", 4],
	"Entei" : ["Pokemon", 3],
	"Palkia" : ["Pokemon", 2],
	"Lugia" : ["Pokemon", 1],
	"CloneTrooper" : ["Star Wars", 4],
	"AsajjVentress" : ["Star Wars", 4],
	"BattleDroid" : ["Star Wars", 4],
	"DrNuvoVindi" : ["Star Wars", 3],
	"CadBane" : ["Star Wars", 3],
	"ObiWan" : ["Star Wars", 2],
	"GeneralLokDurd" : ["Star Wars", 1],
	"DoomShroom" : ["PvZ", 4],
	"Repeater" : ["PvZ", 4],
	"WinterMelon" : ["PvZ", 4],
	"FootballZombie" : ["PvZ", 3],
	"BalloonZombie" : ["PvZ", 3],
	"GatlingPea" : ["PvZ", 2],
	"CrazyDave" : ["PvZ", 1],
	"ChuckE" : ["Rodent", 1],
	"Remy" : ["Rodent", 1],
	"MickeyMouse" : ["Rodent", 1],
	"Jerry" : ["Rodent", 1],
	"SpeedyGonzales" : ["Rodent", 1]
}

var turnTimer = 150
var blindAmount = 10
var dir
var exploreFactor = 10
var deck = []
var simulationMode = 1
var gamesToSimulate = 1000
var playersToDamage = []
# Called when the node enters the scene tree for the first time.
var HandBuilding = 1
var P1Hand = []
var P2Hand = []
var P3Hand = []
var P4Hand = []

var altDown = false

func _ready():
	dir = OS.get_executable_path().get_base_dir()
	dir.replace("\\", "/")
	resetDeck()

func resetDeck():
	randomize()
	for card in cards:
		var count = 0
		while count < cards[card][1]:
			deck.append([card, cards[card][0]])
			count += 1
	deck.shuffle()
	deck.push_front(["NickFury", "Marvel"])
	deck.push_front(["NickFury", "Marvel"])
	deck.push_front(["NickFury", "Marvel"])
	deck.push_front(["NickFury", "Marvel"])
	
func reparent(node, newParent):
	var parent = node.get_parent()
	parent.remove_child(node)
	parent.get_parent().get_node(newParent).add_child(node)
	
func getMyPlayer():
	for player in get_tree().get_nodes_in_group("Players"):
		if player.name == Network.self_data.name:
			return player
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func getActiveMinion(player):
	if player.find_node("Active").get_child_count() != 0:
		return player.find_node("Active").get_children()[0]
	return null

func hasActiveMinion(player):
	if player.find_node("Active").get_child_count() <= 0:
		return false
	return true

func isHandEmpty(player):
	if player.find_node("Hand").get_child_count() == 0:
		return true
	return false

func getHand(player):
	if isHandEmpty(player):
		return null
	return player.find_node("Hand").get_children()

func getHandCards(player):
	if isHandEmpty(player):
		return null
	var resultArr = []
	for card in getHand(player):
		resultArr.append(card.cardName)
	return resultArr

func isDiscardEmpty(player):
	if player.find_node("Discard").get_child_count() == 0:
		return true
	return false

func getDiscard(player):
	if isDiscardEmpty(player):
		return []
	#var discard = player.find_node("Discard").get_children()
	#iscard.invert()
	return player.find_node("Discard").get_children()
	
func getTentativeHand(player):
	var tentativeHand = []
	if player.get_node("BettingPhase/Preflop").get_child_count() < 2:
		return tentativeHand
	tentativeHand += player.get_node("BettingPhase/Preflop").get_children()
	
	if player.get_node("BettingPhase/3rdSlot").get_child_count == 0:
		return tentativeHand
	tentativeHand += player.get_node("BettingPhase/3rdSlot").get_children()
	
	if player.get_node("BettingPhase/4thSlot").get_child_count == 0:
		return tentativeHand
	tentativeHand += player.get_node("BettingPhase/4thSlot").get_children()

	if player.get_node("BettingPhase/5thSlot").get_child_count == 0:
		return tentativeHand
	tentativeHand += player.get_node("BettingPhase/5thSlot").get_children()
	
func killMinion(minion, murderer):
	if not minion in minion.minionOwner.discard:
		minion.minionOwner.discard.push_front(minion)
	reparent(minion, "Discard")
	minion.killedBy = murderer
	if not "Hollow" in minion.attributes and not "Hollow" in minion.baseAttributes:
		playersToDamage.append(minion.minionOwner)

func resetMinion(minion):
	minion.attack = minion.baseAttack
	minion.damageThreshold = minion.baseAttack
	minion.externalBuffs = 0
	minion.attackingMinion = null
	minion.attackingPlayer = null
	minion.target = null
	minion.targetPlayer = null
	minion.killedBy = null
	minion.attributes.clear()
	
func determinePlay(minion):
	var player = minion.minionOwner
	var stack = 0
	var bonusType
	if isDiscardEmpty(player):
		bonusType = "vanilla"
		player.playsThisRound.append([minion.cardName, bonusType, ""])
		return
	var discard = getDiscard(player)
	if discard[0].cardName == minion.cardName:
		bonusType = "dupeBonus"
		for card in discard:
			if card.cardName == minion.cardName:
				stack += 1
			else:
				break
		player.playsThisRound.append([minion.cardName, bonusType, stack, ""])
		return
	elif (minion.universe in discard[0].universeTriggers) or MACHINECheck(minion, discard[0]):
		bonusType = "classBonus"
		for card in discard:
			if (minion.universe in card.universeTriggers) or MACHINECheck(minion, card):
				stack += 1
			else:
				break
		player.playsThisRound.append([minion.cardName, bonusType, stack, ""])
		return
	else:
		bonusType = "vanilla"
		player.playsThisRound.append([minion.cardName, bonusType, ""])
		return
	
func MACHINECheck(activeMinion, card):
	if activeMinion.universe == "Team Fortress":
		if card.cardName == "M.A.C.H.I.N.E.":
			return true
		return false
	return false
	
func _input(event):
	if event.is_action_pressed("Alt"):
		altDown = true
	if event.is_action_released("Alt"):
		altDown = false
	
func magnify(card):
	card.scale *= 4.75
	if not card.z_index > 300:
		card.z_index += 500	
	card.magnified = true

func demagnify(card, newScale):
	card.scale = newScale
	card.z_index -= 500
	card.magnified = false

#fix for alt-tabs
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		pass
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		altDown = false
