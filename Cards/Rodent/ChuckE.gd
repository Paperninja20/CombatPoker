extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Chuck E. Cheese"
export var baseAttack = 0
export var attack = 0
export var rarity = "Legendary"
export var universe = "Rodent"
var universeTriggers = Global.classes
var attackingMinion = null
var attackingPlayer = null
var target = null
var targetPlayer = null
var killedBy = null
var damageThreshold = 0
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
	#discard = Global.getDiscard(minionOwner)
	#if discard.size() == 0:
		#return
	pass
	
func activateBox():
	#determineBox()
	damageThreshold = baseAttack
	attack = baseAttack
	#discard = Global.getDiscard(minionOwner)
	attack += target.externalBuffs
	if target != attackingMinion:
		attack += attackingMinion.externalBuffs
	if attack < 0:
		attack = 0
	damageThreshold = attack
	
func trigger():
	determineBox()
	if activeBox != -1:
		if Global.isHandEmpty(minionOwner):
			return
		var rodentCount = 0
		for card in Global.getHand(minionOwner):
			if card.universe == universe:
				rodentCount += 1
		if rodentCount == 4:
			var tempTarget = targetPlayer
			while tempTarget != minionOwner:
				tempTarget.takeDamage(tempTarget.health + 1)
				tempTarget = tempTarget.targeting

func lastLaugh():
	#determineBox()
	pass
	
func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func endRound():
	pass
	

