extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "General Lok Durd of the Separatist Alliance"
var idName = "GeneralLokDurd"
export var baseAttack = 9
export var attack = 9
export var rarity = "Legendary"
export var universe = "Star Wars"
var universeTriggers = ["Star Wars"]
var attackingMinion = null
var attackingPlayer = null
var target = null
var targetPlayer = null
var killedBy = null
var damageThreshold = 9
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
	

