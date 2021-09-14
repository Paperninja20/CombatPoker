extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Asajj Ventress"
var idName = "AsajjVentress"
export var baseAttack = 2
export var attack = 2
export var rarity = "Common"
export var universe = "Star Wars"
var universeTriggers = ["Star Wars"]
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

func _ready():
	minionOwner = get_parent().get_parent()

func determineBox():
	discard = Global.getDiscard(minionOwner)
	if discard.size() == 0:
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
		var debuff = 0
		for card in discard:
			if card.cardName == cardName:
				debuff -= 4
		externalBuffs = debuff
			
	elif activeBox == 2:
		var debuff = 0
		for card in discard:
			if universe in card.universeTriggers:
				debuff -= 2
		externalBuffs = debuff
			
	attack += target.externalBuffs
	if target != attackingMinion:
		attack += attackingMinion.externalBuffs
	if attack < 0:
		attack = 0
	damageThreshold = attack
	
func trigger():
	pass

func lastLaugh():
	pass

func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func endRound():
	pass
	
