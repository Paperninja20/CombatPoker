extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Ant-Man"
export var baseAttack = 1
export var attack = 1
export var rarity = "Common"
export var universe = "Marvel"
var universeTriggers = ["Marvel"]
var attackingMinion = null
var attackingPlayer = null
var target = null
var targetPlayer = null
var killedBy = null
var damageThreshold = 1
var activeBox = 0
var attributes = []
var baseAttributes = []
var externalBuffs = 0
var hand
var active
var discard
var minionOwner

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
	discard = Global.getDiscard(minionOwner)
	attack = baseAttack
	damageThreshold = baseAttack
	if activeBox == 1:
		for card in discard:
			if card.cardName == cardName:
				attack += 4
			else:
				break
	elif activeBox == 2:
		for card in discard:
			if universe in card.universeTriggers:
				attack += 3
			else:
				break
				
	attack += target.externalBuffs
	if target != attackingMinion:
		attack += attackingMinion.externalBuffs
	if attack < 0:
		attack = 0
	damageThreshold = attack
	
func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
	
func trigger():
	pass

func lastLaugh():
	pass

