extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = ""
export var baseAttack = 1
export var attack = 1
export var rarity = "Common"
export var universe = ""
var universeTriggers = [""]
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
	

