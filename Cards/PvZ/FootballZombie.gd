extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Football Zombie"
var idName = "FootballZombie"
export var baseAttack = 5
export var attack = 5
export var rarity = "Rare"
export var universe = "PvZ"
var universeTriggers = ["PvZ"]
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
	if consecutiveGreen >= 2:
		activeBox = 1
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
	damageThreshold = attack
	
func trigger():
	determineBox()
	if activeBox == 1:
		var tempTarget = targetPlayer
		while tempTarget != minionOwner:
			tempTarget.discardCard()
			tempTarget = tempTarget.targeting

func lastLaugh():
	determineBox()
	if activeBox != -1:
		minionOwner.discardCard()
	
func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func endRound():
	pass
	
