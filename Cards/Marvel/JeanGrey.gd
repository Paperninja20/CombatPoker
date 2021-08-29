extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Jean Grey"
export var baseAttack = 5
export var attack = 5
export var rarity = "Epic"
export var universe = "Marvel"
var universeTriggers = ["Marvel"]
var attackingMinion = null
var attackingPlayer = null
var target = null
var targetPlayer = null
var killedBy = null
var damageThreshold = 5
var activeBox = 0
var attributes = []
var baseAttributes = []
var externalBuffs = 0
var hand
var active
var discard
var minionOwner
var triggered = false
var buffTriggered = false

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
	attack = baseAttack
	damageThreshold = baseAttack
	attack += target.externalBuffs
	if target != attackingMinion:
		attack += attackingMinion.externalBuffs
	if attack < 0:
		attack = 0
	damageThreshold = attack
	
func trigger():
	determineBox()
	if activeBox == 1:
		Global.resetMinion(minionOwner.discard[0])
		Global.reparent(minionOwner.discard[0], "Hand")
		minionOwner.discard.pop_front()
		attack += 5
		damageThreshold = attack
		buffTriggered = true
	elif activeBox == 2:
		Global.resetMinion(minionOwner.discard[0])
		Global.reparent(minionOwner.discard[0], "Hand")
		minionOwner.discard.pop_front()
		triggered = true

func lastLaugh():
	pass
	
func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func endRound():
	if buffTriggered:
		attack -= 5
		damageThreshold = attack
		triggered = false
		$AttackLabel.update()
		

