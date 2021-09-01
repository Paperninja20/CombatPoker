extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Spy"
var idName = "Spy"
export var baseAttack = 4
export var attack = 4
export var rarity = "Rare"
export var universe = "Team Fortress"
var universeTriggers = ["Team Fortress"]
var attackingMinion = null
var attackingPlayer = null
var target = null
var targetPlayer = null
var killedBy = null
var damageThreshold = 4
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
	var consecutiveGreen = 0
	for card in discard:
		if universe in card.universeTriggers:
			consecutiveGreen += 1
		else:
			break
	if consecutiveGreen >= 4:
		activeBox = 1
	elif universe in discard[0].universeTriggers:
		activeBox = 2
	else:
		activeBox = 0
	
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
	if triggered:
		damageThreshold = 9999
	else:
		damageThreshold = attack
	
func trigger():
	determineBox()
	if activeBox == 1:
		targetPlayer.takeDamage(targetPlayer.health)
		damageThreshold = 9999
		triggered = true
	elif activeBox == 2:
		targetPlayer.takeDamage(1)

func lastLaugh():
	#determineBox()
	pass
	
func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func endRound():
	triggered = false
	pass
	

