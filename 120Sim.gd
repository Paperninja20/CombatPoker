extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var participant = preload("res://Player.tscn")
var remainingPlayers = []
var minionPhase = true
var gameOver = false
var handToCheck = Global.P1Hand
var deck = []
var handPermutations = []
var sortedData = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var results = File.new()
	var path = Global.dir
	results.open(path + "\\winningHands.txt", File.WRITE)
	
	for entry in Global.deck:
		deck.append(entry)
	if handToCheck.size() < 5:
		$Message.text = "Please select all 5 cards!"
		$Back.visible = true
		$Back2.visible = true
	
	else:
		permute([], handToCheck)
		
		var count = 0
		for hand in handPermutations:
			Global.deck = deck.duplicate(true)
			if simulateGame(hand):
				sortedData.append([hand, "WON"])
			else:
				sortedData.append([hand, "LOST"])
			count += 1
			if count == 120:
				break
			
		var wins = []
		var losses = []
		for data in sortedData:
			if data[1] == "WON":
				wins.append(data)
			else:
				losses.append(data)
				
		sortedData = wins + losses
		for hand in sortedData:
			results.store_line("ORDER: " + str(hand[0]) + " ---- RESULT: " + str(hand[1]))

		$Message.text = "Finished Calculating!"
		$Back.visible = true
		$Back2.visible = true


class winLossSort:
	static func winFirst(a, b):
		if a[1] == "WON":
			return true
		if b[1] == "LOST":
			return false
		
func permute(currentHand, possibleCards):
	if possibleCards.size() == 0:
		handPermutations.append(currentHand)
		return
	for card in possibleCards:
		var newHand = currentHand.duplicate(true)
		newHand.append(card)
		var newPossibleCards = possibleCards.duplicate(true)
		newPossibleCards.erase(card)
		permute(newHand, newPossibleCards)

	
	
func simulateGame(permutationOfHand):
	
	remainingPlayers.clear()
	playerCount(Global.playerCount)
	var allPlayers = remainingPlayers.duplicate(true)
	determineTargeting()
	
	#drawCards
	for player in remainingPlayers:
		match player.playerName:
			"P1":
				var count = 0
				for card in permutationOfHand:
					player.drawCard(card)
					count += 1
				player.draw(5 - count)
			"P2":
				var count = 0
				for card in Global.P2Hand:
					player.drawCard(card)
					count += 1
				player.draw(5 - count)	
			"P3":
				var count = 0
				for card in Global.P3Hand:
					player.drawCard(card)
					count += 1
				player.draw(5 - count)	
			"P4":
				var count = 0
				for card in Global.P4Hand:
					player.drawCard(card)
					count += 1
				player.draw(5 - count)	
	
	
	
	while remainingPlayers.size() > 1:
		playMinions()
		attackPhase()
		
	var didHandWin = false
	if remainingPlayers.size() == 1:
		if remainingPlayers[0].playerName == "P1":
			didHandWin = true
	
	for player in allPlayers:
		player.call_deferred("free")
	
	if didHandWin:
		return true
	else:
		return false

		
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
	
	var playersToRemove = []
	#update minion targets
	for player in remainingPlayers:
		if not Global.hasActiveMinion(player):
			playersToRemove.append(player)
			
	for player in playersToRemove:
		remainingPlayers.erase(player)
	
	determineTargeting()
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
		Player1.position = Vector2(1400, 540)
		#Player1.scale = Vector2(1.5, 1.5)
		add_child(Player1)
		remainingPlayers.append(Player1)
		var Player2 = participant.instance()
		Player2.playerName = "P2"
		Player2.position = Vector2(500, 540)
		#Player2.scale = Vector2(1.5, 1.5)
		add_child(Player2)
		remainingPlayers.append(Player2)
	if number == 3:
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
		$Next/Phase.text = "Enter Attack Phase"
		playMinions()
	else:
		$Next/Phase.text = "Enter Minion Playing Phase"
		attackPhase()


func _on_Back_pressed():
	get_tree().change_scene("res://MainMenu.tscn")


func _on_Back2_pressed():
	get_tree().change_scene("res://CustomSimOptions.tscn")
