extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Heavy"
export var baseAttack = 5
export var attack = 5
export var rarity = "Epic"
export var universe = "Team Fortress"
var universeTriggers = ["Team Fortress"]
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
	if discard[0].cardName == cardName or discard[0].cardName == "M.A.C.H.I.N.E.":
		activeBox = 1
	elif universe in discard[0].universeTriggers:
		activeBox = 2
	else:
		activeBox = 0
	
func activateBox():
	determineBox()
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
		var spray = 0
		if not Global.deck[0][1] == universe:
			spray += 1
		if not Global.deck[1][1] == universe:
			spray += 1
		if not Global.deck[2][1] == universe:
			spray += 1
			
		var tempTarget = targetPlayer
		while tempTarget != minionOwner:
			tempTarget.takeDamage(spray)
			tempTarget = tempTarget.targeting
		print("Heavy Dealt " + str(spray) + " aoe")
			
			

func lastLaugh():
	pass
	
func doAttack():
	determineBox()
	if activeBox == 2:
		var bloodshed = []
		var tempTarget = target
		while tempTarget != self:
			if attack >= tempTarget.damageThreshold:
				bloodshed.append([tempTarget, self])
			tempTarget = tempTarget.target
		return bloodshed
	else:
		if attack >= target.damageThreshold:
			return [[target, self]]
		else:
			return []
		
func endRound():
	pass
	

