extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var participant = preload("res://Player.tscn")
var remainingPlayers = []
var minionPhase = true
var gameOver = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	playerCount(4)
	determineTargeting()
	
	#drawCards
	for player in remainingPlayers:
		player.draw(5)
		
	#GAME SEQUENCE
	#########

func playMinions():
	#update targeting after players died
	determineTargeting()
	
	var newMinionsPlayed = []
	minionPhase = false
	for player in remainingPlayers:
		var minion = player.playMinion()
		if minion != null:
			newMinionsPlayed.append(minion)
	
	#update minion targets
	for player in remainingPlayers:
		player.determineAdjacentMinions()

	#activate boxes
	for player in remainingPlayers:
		Global.getActiveMinion(player).activateBox()
		Global.getActiveMinion(player).get_node("AttackLabel").update()
		
	#trigger phase and update Labels and status
	for minion in newMinionsPlayed:
		minion.trigger()
		minion.activateBox()
		minion.get_node("AttackLabel").update()
	
	for player in remainingPlayers:
		Global.getActiveMinion(player).activateBox()
		Global.getActiveMinion(player).get_node("AttackLabel").update()
		
	
func attackPhase():
	minionPhase = true
	#attack phase
	
	Global.playersToDamage = []
	var deathsFromAttacks = []
	for player in remainingPlayers:
		var activeMinion = Global.getActiveMinion(player)
		deathsFromAttacks += activeMinion.doAttack()
	
	#death discards resolve
	for death in deathsFromAttacks:
		var killedMinion = death[0]
		var murderer = death[1]
		if murderer.has_method("devour"):
			murderer.devour(killedMinion)
		else:
			Global.killMinion(killedMinion, murderer)
			
	#last laugh phase
	for death in deathsFromAttacks:
		var killedMinion = death[0]
		if killedMinion.has_method("lastLaugh"):
			killedMinion.lastLaugh()
	
	#update statuses and health
	for player in remainingPlayers:
		if not player in Global.playersToDamage:
			if Global.hasActiveMinion(player):
				player.takeDamage(-1)
				var minion = Global.getActiveMinion(player)
				minion.activateBox()
				minion.get_node("AttackLabel").update()
			else:
				continue
		else:
			player.takeDamage(1)
		
	#find eliminated players
	var newlyDead = []
	for player in remainingPlayers:
		#if player is at 0 health
		if player.health <= 0:
			newlyDead.append(player)
			player.get_node("Eliminated").visible = true
			continue
		#if player is out of steam
		if Global.isHandEmpty(player) and not Global.hasActiveMinion(player):
			newlyDead.append(player)
			player.get_node("Eliminated").visible = true
	
	#remove players from game
	if newlyDead.size() > 0:
		for player in newlyDead:
			remainingPlayers.erase(player)
		
	#check for win
	if remainingPlayers.size() <= 1:
		gameOver = true
		if remainingPlayers.size() == 1:
			$Label.text = remainingPlayers[0].playerName + " wins!"
		else:
			$Label.text = "pot split!"
		$Label.visible = true
		get_tree().paused = true
	
	for player in remainingPlayers:
		var activeMinion = Global.getActiveMinion(player)
		if activeMinion != null:
			if activeMinion.has_method("endRound"):
				activeMinion.endRound()
	
func determineTargeting():
	for i in range(0, remainingPlayers.size()):
		if i == 0:
			remainingPlayers[i].targetedBy = remainingPlayers[remainingPlayers.size() - 1]
		else:
			remainingPlayers[i].targetedBy = remainingPlayers[i - 1]
		if i == remainingPlayers.size() - 1:
			remainingPlayers[i].targeting = remainingPlayers[0]
		else:
			remainingPlayers[i].targeting = remainingPlayers[i + 1]

func playerCount(number):
	if number == 2:
		var Player1 = participant.instance()
		Player1.playerName = "P1"
		Player1.position = Vector2(1350, 540)
		add_child(Player1)
		remainingPlayers.append(Player1)
		var Player2 = participant.instance()
		Player2.playerName = "P2"
		Player2.position = Vector2(550, 540)
		add_child(Player2)
		remainingPlayers.append(Player2)
	if number == 3:
		$TextureButton.rect_position = Vector2(1500, 700)
		var Player1 = participant.instance()
		Player1.playerName = "P1"
		Player1.position = Vector2(1600, 350)
		add_child(Player1)
		remainingPlayers.append(Player1)
		var Player2 = participant.instance()
		Player2.playerName = "P2"
		Player2.position = Vector2(960, 800)
		add_child(Player2)
		remainingPlayers.append(Player2)
		var Player3 = participant.instance()
		Player3.playerName = "P3"
		Player3.position = Vector2(300, 350)
		add_child(Player3)
		remainingPlayers.append(Player3)
	if number == 4:
		var Player1 = participant.instance()
		Player1.playerName = "P1"
		Player1.position = Vector2(1400, 300)
		add_child(Player1)
		remainingPlayers.append(Player1)
		var Player2 = participant.instance()
		Player2.playerName = "P2"
		Player2.position = Vector2(1400, 800)
		add_child(Player2)
		remainingPlayers.append(Player2)
		var Player3 = participant.instance()
		Player3.playerName = "P3"
		Player3.position = Vector2(300, 800)
		add_child(Player3)
		remainingPlayers.append(Player3)
		var Player4 = participant.instance()
		Player4.playerName = "P4"
		Player4.position = Vector2(300, 300)
		add_child(Player4)
		remainingPlayers.append(Player4)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_TextureButton_pressed():
	if gameOver:
		return
	if minionPhase:
		playMinions()
	else:
		attackPhase()
