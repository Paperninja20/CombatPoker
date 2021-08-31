extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var playerName
var health = 3
var targetedBy
var targeting
var handIndex = 0
var discard = []

var playsThisRound = []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	health = 3
	add_to_group("playersAlive")
	pass # Replace with function body.


func playMinion():
	if Global.hasActiveMinion(self):
		return null
#	var choice = randi() % $Hand.get_child_count()
#	Global.reparent($Hand.get_children()[choice], "Active")
	if Global.isHandEmpty(self):
		return
	var playedMinion = $Hand.get_children()[0]
	playedMinion.position.x = 0
	Global.reparent(playedMinion, "Active")
	Global.determinePlay(playedMinion)
	if Global.isHandEmpty(self):
		if discard.size() != 0:
			if discard[discard.size() - 1].cardName == "Captain America":
				Global.resetMinion(discard[discard.size() - 1])
				Global.reparent(discard[discard.size() - 1], "Hand")
	return playedMinion
	
func draw(count):
	for _i in range(0, count):
		var deck = Global.deck
		#var randIndex = randi() % deck.size()
		var card = load("res://Cards/" + deck[0][1] + "/" + deck[0][0] + ".tscn")
		var newCard = card.instance()
		newCard.position.x = handIndex
		handIndex += 180
		$Hand.add_child(newCard)
		deck.remove(0)
		
		playsThisRound.append([newCard.cardName, "drawn", ""])

func drawCard(cardName):
	var cardUniverse = Global.cards[cardName][0]
	var card = load("res://Cards/" + cardUniverse + "/" + cardName + ".tscn")
	var newCard = card.instance()
	newCard.position.x = handIndex
	handIndex += 180
	$Hand.add_child(newCard)
	Global.deck.erase([cardName, cardUniverse])
	playsThisRound.append([newCard.cardName, "drawn", ""])
	
func takeDamage(damage):
	health -= damage
	if health > 5:
		health = 5
	$Label.update()
	
func discardCard():
	if not Global.isHandEmpty(self):
		var discardedCard = $Hand.get_children()[0]
		discardedCard.position.x = 0
		discard.push_front(discardedCard)
		Global.reparent(discardedCard, "Discard")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func determineAdjacentMinions():
	if not Global.hasActiveMinion(self):
		return
	var active = Global.getActiveMinion(self)
	while not Global.hasActiveMinion(targetedBy):
		targetedBy = targetedBy.targetedBy
	while not Global.hasActiveMinion(targeting):
		targeting = targeting.targeting
	active.attackingPlayer = targetedBy
	active.attackingMinion = Global.getActiveMinion(targetedBy)
	active.targetPlayer = targeting
	active.target = Global.getActiveMinion(targeting)

func _on_TextureButton_button_down():
	var x = 960 - (195 * discard.size())/2
	var y = 540
	for card in discard:
		card.scale *= 1.5
		card.z_index += 3
		card.global_position = Vector2(x, y)
		x += 195

func _on_TextureButton_button_up():
	for card in discard:
		card.position = Vector2(0, 0)
		card.z_index -= 3
		card.scale /= 1.5
