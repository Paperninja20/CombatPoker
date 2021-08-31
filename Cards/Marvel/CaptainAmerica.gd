extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Captain America"
var idName = "CaptainAmerica"
export var baseAttack = 1
export var attack = 1
export var rarity = "Legendary"
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
var triggered = false

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
				attack += 4
			else:
				break
	if Global.getActiveMinion(minionOwner) == self:
		attack += target.externalBuffs
		if target != attackingMinion:
			attack += attackingMinion.externalBuffs
		if attack < 0:
			attack = 0
		damageThreshold = attack
	
func trigger():
	determineBox()
	if activeBox == 0:
		if minionOwner.discard.size() != 0:
			return
		Global.killMinion(self, self)
		var newMinion = minionOwner.playMinion()
		if newMinion == null:
			return
		target.attackingMinion = newMinion
		attackingMinion.target = newMinion
		newMinion.target = target
		newMinion.attackingMinion = attackingMinion
		newMinion.determineBox()
		newMinion.activateBox()
		newMinion.get_node("AttackLabel").update()
		newMinion.trigger()
	triggered = true
		
func lastLaugh():
	pass

func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func endRound():
	pass


