extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Scout"
export var baseAttack = 3
export var attack = 3
export var rarity = "Common"
export var universe = "Team Fortress"
var universeTriggers = ["Team Fortress"]
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
	if discard[0].cardName == cardName or discard[0].cardName == "M.A.C.H.I.N.E.":
		activeBox = 1
	
func activateBox():
	determineBox()
	damageThreshold = baseAttack
	attack = baseAttack
	if activeBox == 1:
		discard = Global.getDiscard(minionOwner)
		for card in discard:
			if card.cardName == cardName or card.cardName == "M.A.C.H.I.N.E.":
				attack += 5
			else:
				break
	attack += target.externalBuffs
	if target != attackingMinion:
		attack += attackingMinion.externalBuffs
	if attack < 0:
		attack = 0
	damageThreshold = attack
	
func trigger():
	#determineBox()
	pass

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
	

