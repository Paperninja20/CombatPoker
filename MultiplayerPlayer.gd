extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var seat = 0


var id = 0
var playerName
var health = 3
var targetedBy
var targeting
var handIndex = 0
var discard = []

var keeps = []
var discards = []

var playsThisRound = []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	health = 3
	add_to_group("playersAlive")
	reorient()
	pass # Replace with function body.


func playMinion():
	if Global.hasActiveMinion(self):
		return null
#	var choice = randi() % $Hand.get_child_count()
#	Global.reparent($Hand.get_children()[choice], "Active")
	if Global.isHandEmpty(self):
		return
	var playedMinion = find_node('Hand').get_children()[0]
	playedMinion.position.x = 0
	Global.reparent(playedMinion, "Active")
	Global.determinePlay(playedMinion)
	playedMinion.get_node("Cardback").visible = false
	capCheck()
	return playedMinion
			
func playBetterMinion():
	if discard.size() == 0:
		return null
	for card in Global.getHand(self):
		if card.cardName == discard[0].cardName:
			var playedMinion = card
			playedMinion.position.x = 0
			Global.reparent(playedMinion, "Active")
			Global.determinePlay(playedMinion)
			capCheck()
			return playedMinion
	for card in Global.getHand(self):
		if card.universe in discard[0].universeTriggers:
			var playedMinion = card
			playedMinion.position.x = 0
			Global.reparent(playedMinion, "Active")
			Global.determinePlay(playedMinion)
			capCheck()
			return playedMinion
		
		
func draw(count):
	for _i in range(0, count):
		var deck = Global.deck
		#var randIndex = randi() % deck.size()
		var card = load("res://Cards/" + deck[0][0] + ".tscn")
		var newCard = card.instance()
		var handPos = 0
		for existingCard in $CombatPhase/Hand.get_children():
			existingCard.position.x = handPos
			handPos += 180
		newCard.position.x += 180 * $CombatPhase/Hand.get_child_count()
		$CombatPhase/Hand.add_child(newCard)
		newCard.minionOwner = self
		
		if self.is_network_master():
			var handButton = load("res://HandButton.tscn")
			var newButton = handButton.instance()
			newCard.add_child(newButton)
			newCard.move_child(newButton, 0)
		else:
			newCard.get_node("Cardback").visible = true
		
		deck.remove(0)
		
		playsThisRound.append([newCard.cardName, "drawn", ""])

func drawCard(cardName):
	var cardUniverse = Global.cards[cardName][0]
	var card = load("res://Cards/" + cardName + ".tscn")
	var newCard = card.instance()
	newCard.position.x = handIndex
	handIndex += 180
	$CombatPhase/Hand.add_child(newCard)
	Global.deck.erase([cardName, cardUniverse])
	playsThisRound.append([newCard.cardName, "drawn", ""])
	
func drawPreflop():
	var deck = Global.deck
	#var randIndex = randi() % deck.size()
	var card = load("res://Cards/" + deck[0][0] + ".tscn")
	var card1 = card.instance()
	card1.position.x += 180 * $BettingPhase/Keeps.get_child_count()
	$BettingPhase/Keeps.add_child(card1)
	deck.remove(0)
	
	card = load("res://Cards/" + deck[0][0] + ".tscn")
	var card2 = card.instance()
	card2.position.x += 180 * $BettingPhase/Keeps.get_child_count()
	$BettingPhase/Keeps.add_child(card2)
	deck.remove(0)
	
	Network.gamestate[self.get_name()] = {}
	Network.gamestate[self.get_name()]["Keeps"] = [card1.idName, card2.idName]
	

func resetAll():
	resetBettingArea()
	for child in $CombatPhase/Hand.get_children():
		$CombatPhase/Hand.remove_child(child)
		child.queue_free()
	for child in $CombatPhase/Active.get_children():
		$CombatPhase/Active.remove_child(child)
		child.queue_free()
	for child in $CombatPhase/Discard.get_children():
		$CombatPhase/Discard.remove_child(child)
		child.queue_free()
	$CombatPhase/Lives.text = '3'
	$Eliminated.visible = false
	$CombatPhase.visible = false
	$BettingPhase.visible = true
	health = 3
	discard.clear()
	keeps.clear()
	discards.clear()
	


func resetBettingArea():
	for child in $BettingPhase/Keeps.get_children():
		$BettingPhase/Keeps.remove_child(child)
		child.queue_free()
	for child in $BettingPhase/Discards.get_children():
		$BettingPhase/Discards.remove_child(child)
		child.queue_free()
	$BettingPhase/BetAmount.text = '0'
	$BettingPhase/BetAmount.visible = false
	$BettingPhase/Capsule.visible = false
	$BettingPhase.visible = false

func transitionHand():
	for card in $BettingPhase/Keeps.get_children():
		if not card.get_node("Cardback").visible:
			keeps.append(card.idName)
		$BettingPhase/Keeps.remove_child(card)
		$CombatPhase/Hand.add_child(card)
		card.oldPos = card.global_position
		card.minionOwner = self
		if not self.is_network_master():
			card.get_node("Cardback").visible = true
		else:
			var handButton = load("res://HandButton.tscn")
			var newButton = handButton.instance()
			card.add_child(newButton)
			card.move_child(newButton, 0)
			
	for card in $BettingPhase/Discards.get_children():
		discards.append(card.idName)
		Global.demagnify(card, Vector2(1,1))
		$BettingPhase/Discards.remove_child(card)
		card.queue_free()
		
	$BettingPhase/BetAmount.text = '0'
	$BettingPhase/BetAmount.visible = false
	$BettingPhase/Capsule.visible = false
	$BettingPhase.visible = false
	$CombatPhase.visible = true
	
	
func takeDamage(damage):
	if health == 0:
		return
	health -= damage
	if health > 5:
		health = 5
	$CombatPhase/Lives.update()
	
func discardCard():
	if not Global.isHandEmpty(self):
		var discardedCard = $CombatPhase/Hand.get_children()[0]
		discardedCard.position.x = 0
		discard.push_front(discardedCard)
		Global.reparent(discardedCard, "Discard")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func capCheck():
	if Global.isHandEmpty(self):
		if discard.size() != 0:
			if discard[discard.size() - 1].cardName == "Captain America":
				Global.resetMinion(discard[discard.size() - 1])
				Global.reparent(discard[discard.size() - 1], "Hand")
				
func reorient():
	if position.y < 540:
		get_node("BettingPhase/Keeps").position.y = 230
		get_node("BettingPhase/Discards").position.y = 100
		get_node("BettingPhase/Money").rect_position.y = -108
		get_node("BettingPhase/BetAmount").rect_position.y = 305
		get_node("BettingPhase/Capsule").position.y = 343
		get_node("CombatPhase/Active").position.y = 160
		get_node("CombatPhase/Hand").position.y = -100
		get_node("CombatPhase/Discard").position.y = 160
		get_node("CombatPhase/TextureButton").rect_position.y = 75
	if position.y > 540:
		get_node("BettingPhase/Keeps").position.y = -100
		get_node("BettingPhase/Discards").position.y = -230
		get_node("BettingPhase/Money").rect_position.y = 36
		if not self.is_network_master():
			get_node("BettingPhase/BetAmount").rect_position.y = -380
		else:
			get_node("BettingPhase/BetAmount").rect_position.y = -373.71
		get_node("BettingPhase/Capsule").position.y = -343
		get_node("CombatPhase/Active").position.y = -160
		get_node("CombatPhase/Hand").position.y = 100
		get_node("CombatPhase/Discard").position.y = -160
		get_node("CombatPhase/TextureButton").rect_position.y = -245
		
	if position.x < 960:
		get_node("BettingPhase/BetAmount").rect_position.x = 407
		get_node("BettingPhase/Capsule").position.x = 497
	elif position.x > 960:
		get_node("BettingPhase/BetAmount").rect_position.x = -593	
		get_node("BettingPhase/Capsule").position.x = -501	
					
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
	var DiscardNode = find_node("Discard")
	if DiscardNode.get_child_count() <= 0:
		return
		
	var playerDiscard = DiscardNode.get_children()
		
	var x = 960 - (195 * playerDiscard.size())/2
	var y = 540
	for card in playerDiscard:
		var parentScale = scale.x
		card.scale *= 2.5
		card.scale /= parentScale
		card.z_index += 3
		card.global_position = Vector2(x, y)
		x += 325

func _on_TextureButton_button_up():
	var DiscardNode = find_node("Discard")
	if DiscardNode.get_child_count() <= 0:
		return
		
	var playerDiscard = DiscardNode.get_children()
	
	for card in playerDiscard:
		var parentScale = scale.x
		card.scale /= 2.5
		card.scale *= parentScale
		card.position = Vector2(0, 0)
		card.z_index -= 3
		



func _on_BetAmount_visibility_changed():
	if $BettingPhase/BetAmount.visible:
		$BettingPhase/Capsule.visible = true
	else:
		$BettingPhase/Capsule.visible = false
