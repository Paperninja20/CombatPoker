extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Palkia"
var idName = "Palkia"
export var baseAttack = 3
export var attack = 3
export var rarity = "Epic"
export var universe = "Pokemon"
var universeTriggers = ["Pokemon"]
var attackingMinion = null
var attackingPlayer = null
var target = null
var targetPlayer = null
var killedBy = null
var damageThreshold = 3
var activeBox = 0
var attributes = []
var baseAttributes = []
var externalBuffs = 0
var hand
var active
var discard
var minionOwner
var triggered = false
var hovering
var magnified

func _ready():
	minionOwner = get_parent().get_parent()

func determineBox():
	discard = Global.getDiscard(minionOwner)
	if discard.size() == 0:
		activeBox = 0
		return
	if discard[0].cardName == cardName:
		activeBox = 1
	elif universe in discard[0].universeTriggers:
		activeBox = 2
	else:
		activeBox = 0
	
func activateBox():
	determineBox()
	damageThreshold = baseAttack
	attack = baseAttack
	discard = Global.getDiscard(minionOwner)
	if activeBox == 1:
		attack += 3
	attack += target.externalBuffs
	if target != attackingMinion:
		attack += attackingMinion.externalBuffs
	if attack < 0:
		attack = 0
	damageThreshold = attack
	
func preview(on):
	if on:
		determineBox()
		discard = Global.getDiscard(minionOwner)
		var attackPreview = baseAttack
		if activeBox == 1:
			attackPreview += 3
		$AttackLabel.text = str(attackPreview)
		$AttackLabel2.text = str(attackPreview)
	else:
		$AttackLabel.update()
		$AttackLabel2.update()
		
func trigger():
	print("triggered palkia")
	determineBox()
	if activeBox == 1:
		var tempTarget = targetPlayer
		
		#recur and shuffle other players' hands back
		while tempTarget != minionOwner:
			if Global.isHandEmpty(tempTarget):
				continue
			for card in Global.getHand(tempTarget):
				Global.deck.append([card.idName, card.universe])
				card.get_parent().remove_child(card)
				card.queue_free()
			tempTarget = tempTarget.targeting
			
		#shuffle own hand back
		if not Global.isHandEmpty(tempTarget):
			for card in Global.getHand(minionOwner):
				Global.deck.append([card.idName, card.universe])
				card.queue_free()

	elif activeBox == 2:
		get_parent().remove_child(self)
		attackingPlayer.find_node("Active").add_child(self)
		attackingPlayer.find_node("Active").remove_child(attackingMinion)
		minionOwner.find_node("Active").add_child(attackingMinion)
		attackingMinion.minionOwner = minionOwner
		minionOwner = attackingPlayer
		minionOwner.targeting.determineAdjacentMinions()
		minionOwner.determineAdjacentMinions()
		attackingPlayer.determineAdjacentMinions()
		attackingPlayer.targetedBy.determineAdjacentMinions()

func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func endRound():
	pass
	
func _on_Area2D_mouse_entered():
	hovering = true
	if Global.altDown:
		Global.magnify(self)

func _on_Area2D_mouse_exited():
	hovering = false
	if magnified:
		Global.demagnify(self, Vector2(1,1))
	
func _input(event):
	if event.is_action_pressed("Alt"):
		if hovering:
			Global.magnify(self)
	if event.is_action_released("Alt"):
		if magnified:
			Global.demagnify(self, Vector2(1,1))
