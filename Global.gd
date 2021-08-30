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
	"Gible" : ["Pokemon", 4],
	"Entei" : ["Pokemon", 3],
	"Palkia" : ["Pokemon", 2],
	"Lugia" : ["Pokemon", 1],
	"CloneTrooper" : ["Star Wars", 4],
	"CountDooku" : ["Star Wars", 4],
	"Droideka" : ["Star Wars", 4],
	"DrNuvoVindi" : ["Star Wars", 3],
	"CadBane" : ["Star Wars", 3],
	"ObiWan" : ["Star Wars", 2],
	"GeneralLokDurd" : ["Star Wars", 1],
	"Demoman" : ["Team Fortress", 4],
	"Scout" : ["Team Fortress", 4],
	"Soldier" : ["Team Fortress", 4],
	"Pyro" : ["Team Fortress", 3],
	"Spy" : ["Team Fortress", 3],
	"Heavy" : ["Team Fortress", 2],
	"MACHINE" : ["Team Fortress", 1],
	"ChuckE" : ["Rodent", 1],
	"Remy" : ["Rodent", 1],
	"MickeyMouse" : ["Rodent", 1],
	"Jerry" : ["Rodent", 1],
	"SpeedyGonzales" : ["Rodent", 1]
}

var deck = []
var simulationMode = 1
var playersToDamage = []
# Called when the node enters the scene tree for the first time.
var HandBuilding = 1
var P1Hand = ["CaptainAmerica", "JeanGrey", "AntMan", "TheHulk", "NickFury"]
var P2Hand = []
var P3Hand = []
var P4Hand = []

func _ready():
	randomize()
	for card in cards:
		var count = 0
		while count < cards[card][1]:
			deck.append([card, cards[card][0]])
			count += 1
	deck.shuffle()
	
func reparent(node, newParent):
	var parent = node.get_parent()
	parent.remove_child(node)
	parent.get_parent().get_node(newParent).add_child(node)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func getActiveMinion(player):
	if player.get_node("Active").get_child_count() != 0:
		return player.get_node("Active").get_children()[0]
	return null

func hasActiveMinion(player):
	if player.get_node("Active").get_child_count() == 0:
		return false
	return true

func isHandEmpty(player):
	if player.get_node("Hand").get_child_count() == 0:
		return true
	return false

func getHand(player):
	if isHandEmpty(player):
		return null
	return player.get_node("Hand").get_children()

func isDiscardEmpty(player):
	if player.get_node("Discard").get_child_count() == 0:
		return true
	return false

func getDiscard(player):
	if isDiscardEmpty(player):
		return []
	#var discard = player.get_node("Discard").get_children()
	#iscard.invert()
	var discard = player.discard
	return discard

	
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
	
