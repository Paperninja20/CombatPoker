extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Gible"
export var baseAttack = 2
export var attack = 2
export var rarity = "Common"
export var universe = "Pokemon"
var universeTriggers = ["Pokemon"]
var attackingMinion = null
var attackingPlayer = null
var target = null
var targetPlayer = null
var killedBy = null
var damageThreshold = 2
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
	if discard[0].cardName == cardName:
		activeBox = 1
	elif universe in discard[0].universeTriggers:
		activeBox = 2
	else:
		activeBox = 0
		
func activateBox():
	determineBox()
	attack = baseAttack
	damageThreshold = baseAttack
	discard = Global.getDiscard(minionOwner)
	if activeBox == 1:
		attack += 6
	elif activeBox == 2:
		attack += 4
		
	attack += target.externalBuffs
	if target != attackingMinion:
		attack += attackingMinion.externalBuffs
	if attack < 0:
		attack = 0
	damageThreshold = attack
	
func trigger():
	pass

func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func lastLaugh():
	pass


