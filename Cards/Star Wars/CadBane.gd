extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Cad Bane"
var idName = "CadBane"
export var baseAttack = 4
export var attack = 4
export var rarity = "Rare"
export var universe = "Star Wars"
var universeTriggers = ["Star Wars"]
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
var hovering
var magnified
var oldPos

func _ready():
	minionOwner = get_parent().get_parent()
	oldPos = global_position

func determineBox():
	discard = Global.getDiscard(minionOwner)
	if discard.size() == 0:
		return
	if discard.size() == 1 and discard[0] == self:
		return
	if discard[0] == self:
		if universe in discard[1].universe:
			activeBox = 1
		else:
			activeBox = 0
	else:
		if universe in discard[0].universe:
			activeBox = 1
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


func lastLaugh():
	determineBox()
	if activeBox == 1:
		get_parent().remove_child(self)
		var playerWhoKilledCad = killedBy.minionOwner
		playerWhoKilledCad.find_node("Discard").add_child(self)
		playerWhoKilledCad.discard.push_front(self)
		if Global.hasActiveMinion(playerWhoKilledCad):
			Global.getActiveMinion(playerWhoKilledCad).determineBox()
			Global.getActiveMinion(playerWhoKilledCad).activateBox()
			
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
