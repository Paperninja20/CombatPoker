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
var hovering
var magnified
var oldPos

func _ready():
	minionOwner = get_parent().get_parent()
	oldPos = global_position

func determineBox():
	if Global.getHand(minionOwner) != null:
		activeBox = 0
		return
	discard = Global.getDiscard(minionOwner)
	if discard.size() == 0:
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
		
func preview(on):
	if on:
		determineBox()
		discard = Global.getDiscard(minionOwner)
		var attackPreview = baseAttack
		if activeBox == 1:
			for card in discard:
				if universe in card.universeTriggers:
					attackPreview += 4
				else:
					break
		$AttackLabel.text = str(attackPreview)
		$AttackLabel2.text = str(attackPreview)
	else:
		$AttackLabel.update()
		$AttackLabel2.update()
	
func trigger():
	determineBox()
	if activeBox == 0:
		if Global.getHand(minionOwner) == null:
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
		Network.newMinionsPlayed.append(newMinion)
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

func _on_Area2D_mouse_entered():
	hovering = true
	if Global.altDown and not magnified:
		Global.magnify(self)

func _on_Area2D_mouse_exited():
	hovering = false
#	if magnified:
#		Global.demagnify(self, Vector2(1,1))
	
func _input(event):
	if event.is_action_pressed("Alt"):
		if hovering:
			Global.magnify(self)
	if event.is_action_released("Alt"):
		if magnified:
			Global.demagnify(self, Vector2(1,1))
