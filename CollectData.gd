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
var simulationData
var handsThisRound
# Called when the node enters the scene tree for the first time.
func _ready():
	var path = Global.dir
	#print(path)
	for entry in Global.deck:
		deck.append(entry)
		
	var winrates = File.new()
	#match Global.playerCount:
		#2:
		#	winrates.open("res://Winrates2.json", File.READ)
		#3:
		#	winrates.open("res://Winrates3.json", File.READ)
		#4:
		#	winrates.open("res://Winrates4.json", File.READ)
	match Global.playerCount:
		2:
			winrates.open(path + "\\Winrates2.json", File.READ)
		3:
			winrates.open(path + "\\Winrates3.json", File.READ)
		4:
			winrates.open(path + "\\Winrates4.json", File.READ)
	
	var json = JSON.parse(winrates.get_as_text())
	winrates.close()
	var data = json.result
	
	#handsThisRound = File.new()
	#handsThisRound.open("C:/Users/jacob/Desktop/SimulationResults/handsThisRound.txt", File.WRITE)
	
	yield(get_tree().create_timer(0.5), "timeout")
	for _i in range(0, Global.gamesToSimulate):
		#yield(get_tree().create_timer(0.005), "timeout")
		Global.deck = deck.duplicate(true)
		randomize()
		Global.deck.shuffle()
		simulationData = simulateGame()
		
		for information in simulationData:
			if information.size() == 3:
				var cardName = information[0]
				var scenario = information[1]
				var gameResult = information[2]
				
				var currentWins = data[cardName][scenario][0][0]
				var currentLosses = data[cardName][scenario][0][1]
				var currentSample = data[cardName][scenario][1]
				
				if gameResult == "W":
					currentWins += 1
				else:
					currentLosses += 1
				currentSample += 1
				data[cardName][scenario] = [[currentWins, currentLosses], currentSample]
			else:
				var cardName = information[0]
				var bonusType = information[1]
				var bonusLevel = str(information[2])
				var gameResult = information[3]
				
				if not data[cardName][bonusType].has(bonusLevel):
					continue
				var currentWins = data[cardName][bonusType][bonusLevel][0][0]
				var currentLosses = data[cardName][bonusType][bonusLevel][0][1]
				var currentSample = data[cardName][bonusType][bonusLevel][1]
				
				if gameResult == "W":
					currentWins += 1
				else:
					currentLosses += 1
				currentSample += 1
				data[cardName][bonusType][bonusLevel] = [[currentWins, currentLosses], currentSample]
	
	
	winrates = File.new()
	#match Global.playerCount:
		#2:
			#winrates.open("res://Winrates2.json", File.WRITE)
		#3:
			#winrates.open("res://Winrates3.json", File.WRITE)
		#4:
			#winrates.open("res://Winrates4.json", File.WRITE)
	match Global.playerCount:
		2:
			winrates.open(path + "\\Winrates2.json", File.WRITE)
		3:
			winrates.open(path + "\\Winrates3.json", File.WRITE)
		4:
			winrates.open(path + "\\Winrates4.json", File.WRITE)
	winrates.store_string(JSON.print(data, "  ", true))
	winrates.close()
	
	winrates = File.new()
	#match Global.playerCount:
		#2:
			#winrates.open("res://Winrates2.json", File.READ)
		#3:
			#winrates.open("res://Winrates3.json", File.READ)
		#4:
			#winrates.open("res://Winrates4.json", File.READ)
	match Global.playerCount:
		2:
			winrates.open(path + "\\Winrates2.json", File.READ)
		3:
			winrates.open(path + "\\Winrates3.json", File.READ)
		4:
			winrates.open(path + "\\Winrates4.json", File.READ)
	json = JSON.parse(winrates.get_as_text())
	winrates.close()
	data = json.result
	
	formatJSON(data)
	
	$Message.text = "Finished Calculating!"
	$Back.visible = true
	
	#handsThisRound.close()
	
func formatJSON(data):
	var path = Global.dir
	var winrateData = File.new()
	#match Global.playerCount:
		#2:
		#	winrateData.open("C:/Users/jacob/Desktop/SimulationResults/2playerWinrateData.txt", File.WRITE)
		#3:
		#	winrateData.open("C:/Users/jacob/Desktop/SimulationResults/3playerWinrateData.txt", File.WRITE)
		#4:
		#	winrateData.open("C:/Users/jacob/Desktop/SimulationResults/4playerWinrateData.txt", File.WRITE)
	match Global.playerCount:
		2:
			winrateData.open(path + "\\2playerWinrateData.txt", File.WRITE)
		3:
			winrateData.open(path + "\\3playerWinrateData.txt", File.WRITE)
		4:
			winrateData.open(path + "\\4playerWinrateData.txt", File.WRITE)
	for card in data:
		var format_string = "%7.2f"
		var winrate
		var cardData = data[card]
		winrateData.store_line("-------------------------------------\n")

		winrateData.store_line(card + "\n")
		if cardData["drawn"][1] != 0:
			winrate = cardData["drawn"][0][0]/cardData["drawn"][1] * 100
		else:
			winrate = 0
		winrateData.store_line("    drawn: " + format_string % winrate + "% | " + str(cardData["drawn"][1]) + " games")
		if cardData["vanilla"][1] != 0:
			winrate = cardData["vanilla"][0][0]/cardData["vanilla"][1] * 100
		else:
			winrate = 0
		winrateData.store_line("  vanilla: " + format_string % winrate + "% | " + str(cardData["vanilla"][1]) + " games")
		winrateData.store_line("")
		winrateData.store_line("    classBonus: ")
		for stackNum in cardData["classBonus"]:
			var bonus = cardData["classBonus"][stackNum]
			if bonus[1] == 0:
				winrate = 0
			else:
				winrate = bonus[0][0]/bonus[1] * 100
			winrateData.store_line("        " + str(stackNum) + ": " + format_string % winrate + "% | " + str(bonus[1]) + " games")
		winrateData.store_line("")
		winrateData.store_line("    dupeBonus: ")
		for stackNum in cardData["dupeBonus"]:
			var bonus = cardData["dupeBonus"][stackNum]
			if bonus[1] == 0:
				winrate = 0
			else:
				winrate = bonus[0][0]/bonus[1] * 100
			winrateData.store_line("        " + str(stackNum) + ": " + format_string % winrate + "% | " + str(bonus[1]) + " games")
		winrateData.store_line("\n")
	winrateData.close()
		
		
	
	
func simulateGame():
	var roundData = []
	remainingPlayers.clear()
	playerCount(Global.playerCount)
	var allPlayers = remainingPlayers.duplicate(true)
	determineTargeting()
	
	#drawCards
	for player in remainingPlayers:
		player.draw(5)
		#handsThisRound.store_line(str(Global.getHandCards(player)))
	
	#handsThisRound.store_line("  ")
	
	var turnTimer = 20
	while remainingPlayers.size() > 1:
		playMinions()
		attackPhase()
		turnTimer -= 1
		if turnTimer == 0:
			break
	
	var winningPlayer
	if remainingPlayers.size() == 1:
		winningPlayer = remainingPlayers[0]
	
	for player in allPlayers:
		var result
		if winningPlayer == player:
			result = "W"
		else:
			result = "L"
		for play in player.playsThisRound:
			play[-1] = result
		
		roundData += player.playsThisRound
			

		
	for player in allPlayers:
		player.call_deferred("free")
	
	return roundData

		
	#GAME SEQUENCE
	#########

func playMinions():
	#update targeting after players died
	determineTargeting()
	
	#play minions
	var newMinionsPlayed = []
	minionPhase = false
	for player in remainingPlayers:
		var minion = player.playMinion()
		if minion != null:
			newMinionsPlayed.append(minion)
	
	var playersToRemove = []
	#update minion targets
	for player in remainingPlayers:
		if Global.hasActiveMinion(player):
			player.determineAdjacentMinions()
		else:
			playersToRemove.append(player)
			
	for player in playersToRemove:
		remainingPlayers.erase(player)
	
	determineTargeting()
		
	#activate boxes
	for player in remainingPlayers:
		Global.getActiveMinion(player).activateBox()
		#Global.getActiveMinion(player).get_node("AttackLabel").update()
		
	#trigger phase and update Labels and status
	for minion in newMinionsPlayed:
		minion.trigger()
		minion.activateBox()
		#minion.get_node("AttackLabel").update()
	
	for player in remainingPlayers:
		if Global.hasActiveMinion(player):
			Global.getActiveMinion(player).activateBox()
		#Global.getActiveMinion(player).get_node("AttackLabel").update()
		
	
func attackPhase():
	minionPhase = true
	#attack phase
	
	Global.playersToDamage = []
	var deathsFromAttacks = []
	for player in remainingPlayers:
		var activeMinion = Global.getActiveMinion(player)
		#print(player.playerName, Global.getActiveMinion(player))
		if activeMinion == null:
			continue
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
			#.get_node("Eliminated").visible = true
			continue	
		#if player is out of steam
		if Global.isHandEmpty(player) and not Global.hasActiveMinion(player):
			newlyDead.append(player)
			#player.get_node("Eliminated").visible = true
	
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
		Player1.visible = false
		Player1.playerName = "P1"
		Player1.position = Vector2(1400, 540)
		#Player1.scale = Vector2(1.5, 1.5)
		add_child(Player1)
		remainingPlayers.append(Player1)
		var Player2 = participant.instance()
		Player2.visible = false
		Player2.playerName = "P2"
		Player2.position = Vector2(500, 540)
		#Player2.scale = Vector2(1.5, 1.5)
		add_child(Player2)
		remainingPlayers.append(Player2)
	if number == 3:
		var Player1 = participant.instance()
		Player1.visible = false
		Player1.playerName = "P1"
		Player1.position = Vector2(1600, 350)
		add_child(Player1)
		remainingPlayers.append(Player1)
		var Player2 = participant.instance()
		Player2.visible = false
		Player2.playerName = "P2"
		Player2.position = Vector2(960, 800)
		add_child(Player2)
		remainingPlayers.append(Player2)
		var Player3 = participant.instance()
		Player3.visible = false
		Player3.playerName = "P3"
		Player3.position = Vector2(300, 350)
		add_child(Player3)
		remainingPlayers.append(Player3)
	if number == 4:
		var Player1 = participant.instance()
		Player1.visible = false
		Player1.playerName = "P1"
		Player1.position = Vector2(1400, 300)
		add_child(Player1)
		remainingPlayers.append(Player1)
		var Player2 = participant.instance()
		Player2.visible = false
		Player2.playerName = "P2"
		Player2.position = Vector2(1400, 800)
		add_child(Player2)
		remainingPlayers.append(Player2)
		var Player3 = participant.instance()
		Player3.visible = false
		Player3.playerName = "P3"
		Player3.position = Vector2(300, 800)
		add_child(Player3)
		remainingPlayers.append(Player3)
		var Player4 = participant.instance()
		Player4.visible = false
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
