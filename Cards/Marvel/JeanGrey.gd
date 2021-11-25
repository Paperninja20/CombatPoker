extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Jean Grey"
var idName = "JeanGrey"
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
var hovering
var magnified

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
	if buffTriggered:
		attack += 5
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

	
func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func endRound():
	if buffTriggered:
		attack -= 5
		damageThreshold = attack
		buffTriggered = false
		triggered = false
		$AttackLabel.update()
		
func _on_Area2D_mouse_entered():
	hovering = true
	if Global.altDown:
		Global.magnify(self)

func _on_Area2D_mouse_exited():
	hovering = false
	if magnified:
		Global.demagnify(self, Vector2(1,1))
	
func _input(event):
	if event.is_action_pressed("Alt"):
		if hovering:
			Global.magnify(self)
	if event.is_action_released("Alt"):
		if magnified:
			Global.demagnify(self, Vector2(1,1))
