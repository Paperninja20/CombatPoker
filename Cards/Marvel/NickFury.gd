extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Nick Fury"
export var baseAttack = 4
export var attack = 4
export var rarity = "Rare"
export var universe = "Marvel"
var universeTriggers = ["Marvel"]
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
		activeBox = 0
		return
	if universe in discard[0].universeTriggers:
		activeBox = 1
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
		minionOwner.draw(1)

func lastLaugh():
	pass
	
func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
