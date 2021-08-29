extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Dormammu"
export var baseAttack = 3
export var attack = 3
export var rarity = "Rare"
export var universe = "Marvel"
var universeTriggers = ["Marvel"]
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

func _ready():
	minionOwner = get_parent().get_parent()

func determineBox():
	discard = Global.getDiscard(minionOwner)
	if discard.size() == 0:
		activeBox = 0
		return
	if universe in discard[0].universeTriggers:
		activeBox = 1
	else:
		activeBox = 0
	
func activateBox():
	determineBox()
	damageThreshold = baseAttack
	attack = baseAttack
	discard = Global.getDiscard(minionOwner)
	if activeBox == 1:
		for card in discard:
			if universe in card.universeTriggers:
				attack += 2
			else:
				break
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
		
func devour(killedMinion):
	determineBox()
	if activeBox != -1:
		if not killedMinion in killedMinion.minionOwner.discard:
			killedMinion.minionOwner.discard.push_back(killedMinion)
		Global.reparent(killedMinion, "Discard")
		killedMinion.get_parent().move_child(killedMinion, 0)
		killedMinion.killedBy = self
		Global.playersToDamage.append(killedMinion.minionOwner)
