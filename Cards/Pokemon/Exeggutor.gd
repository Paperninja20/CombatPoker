extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var cardName = "Exeggutor"
var idName = "Exeggutor"
export var baseAttack = 3
export var attack = 3
export var rarity = "Common"
export var universe = "Pokemon"
var universeTriggers = ["Pokemon"]
var attackingMinion = null
var attackingPlayer = null
var target = null
var targetPlayer = null
var killedBy = null
var damageThreshold = 3
var activeBox = 0
var attributes = []
var baseAttributes = []
var externalBuffs = 0
var hand
var active
var discard
var minionOwner
var hovering
var magnified
var oldPos

func _ready():
	minionOwner = get_parent().get_parent()
	oldPos = global_position

func determineBox():
	pass
	
func activateBox():
	attack = baseAttack
	damageThreshold = baseAttack
	attack += target.externalBuffs
	if target != attackingMinion:
		attack += attackingMinion.externalBuffs
	if attack < 0:
		attack = 0
	damageThreshold = attack
	
func doAttack():
	if attack >= target.damageThreshold:
		return [[target, self]]
	else:
		return []
		
func lastLaugh():
	determineBox()
	if activeBox != -1:
		Global.killMinion(killedBy, self)

	
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
