extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Dr.Nuvo Vindi"
var idName = "DrNuvoVindi"
export var baseAttack = 0
export var attack = 0
export var rarity = "Rare"
export var universe = "Star Wars"
var universeTriggers = ["Star Wars"]
var attackingMinion = null
var attackingPlayer = null
var target = null
var targetPlayer = null
var killedBy = null
var damageThreshold = 0
var activeBox = 1
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
	

func lastLaugh():
	determineBox()
	if activeBox == 1:
		var discardToTake = Global.getDiscard(killedBy.minionOwner)
		var tempDiscard = discardToTake + minionOwner.discard
		minionOwner.discard = tempDiscard
		for card in discardToTake:
			card.get_parent().remove_child(card)
			minionOwner.find_node("Discard").add_child(card)
		discardToTake.clear()
		var playerWhoKilledDoc = killedBy.minionOwner
		if Global.hasActiveMinion(playerWhoKilledDoc):
			Global.getActiveMinion(playerWhoKilledDoc).determineBox()
			Global.getActiveMinion(playerWhoKilledDoc).activateBox()

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
