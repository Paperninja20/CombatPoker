extends Node


const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 1909
const MAX_PLAYERS = 6

signal turnOver
signal continueGameSequence
signal attackPhase

var gamestate = {}

#	{
#		playerNickname:
#			"Keeps": [cardname, cardname, cardname, cardname, cardname]
#			"Discards": [cardname, cardname]
#			"Hand": [cardname... x5]
#			"Active": [cardname]
#			"Discard": [cardname...]
#	}

var gamestateValues = {}

#var gamestateValues = {
#	playerNickname:
#		Lives: 3
#		ActiveAttack: 5
#		Money: 500
#		BetAmount: 100
#		Eliminated: false
#}

var playsThisTurn = {}
#{
#	playerNickname: play,
#	playerNickname: play,
#	...
#}


remotesync var phase = "preflop"
remotesync var firstRound = true
remotesync var isBigBlind = false
remotesync var isSmallBlind = false
remotesync var currentPot = 0
remotesync var currentBet = Global.blindAmount
remotesync var lastBetter = null
remotesync var firstBetter = null
remotesync var raisedThisRound = false
remotesync var bigBlindCheckedFirstRound = false
remotesync var bigBlindFoldedFirstRound = false

remotesync var big = null
remotesync var small = null

var justFolded = false
var checksAllAround = true
var confirmedFlops = 0
var confirmedTurns = 0
var confirmedRivers = 0
var confirmedPlays = 0 setget setConfirmedPlays, getConfirmedPlays

var clickableHand = false
var newMinionsPlayed = []
var winningPlayers = []
var gameOver = false

var playerOrder = []
var activePlayers = []

var leftSeats = {
	Vector2(360, 750): null,
	Vector2(360, 160): null,
	Vector2(960, 120): null

}

var rightSeats = {
	Vector2(1560, 750): null,
	Vector2(1560, 160): null
}

var players = {}
var self_data = {name = '', money = 500, id = 0}
var player = preload("res://MultiplayerPlayer.tscn")


func _ready():
	pass
	
func CreateLobby(player_nickname, player_money):
	self_data.name = player_nickname
	self_data.money = player_money
	self_data.id = 1
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	
	peer.connect("peer_connected", self, "_Peer_Connected")
	peer.connect("peer_disconnected", self, "_Peer_Disconnected")
	
func JoinLobby(player_nickname, player_money):
	self_data.name = player_nickname
	self_data.money = player_money
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, '_connected_to_server')
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	self_data.id = get_tree().get_network_unique_id()
	
func _connected_to_server():
	players[get_tree().get_network_unique_id()] = self_data
	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data, true)
	
func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	rpc('removePlayer', player_id, players[player_id])
	
remote func _send_player_info(player_id, info, newPlayer):
	if get_tree().is_network_server():
		var reversePlayers = {}
		var reverseKeys = players.keys()
		var reverseVals = players.values()
		reverseKeys.invert()
		reverseVals.invert()
		for i in range(0, players.size()):
			reversePlayers[reverseKeys[i]] = reverseVals[i]
			
		for peer_id in reversePlayers:
			rpc_id(player_id, '_send_player_info', peer_id, players[peer_id], false)
			if peer_id == 1:
				continue
			rpc_id(peer_id, '_send_player_info', player_id, info, true)
			
	players[player_id] = info
	
	var new_player = player.instance()
	new_player.name = info.name
	new_player.id = info.id
	new_player.set_network_master(player_id, true)
	new_player.get_node("PlayerTag").text = info.name
	new_player.get_node("BettingPhase/Money").text = "$" + str(info.money)
	new_player.scale = Vector2(0.65, 0.65)
	if newPlayer:
		var availableSeat = false
		for seat in leftSeats:
			if not leftSeats[seat]:
				new_player.position = seat
				leftSeats[seat] = new_player
				availableSeat = true
				break
		if not availableSeat:
			var reversedRightSeats = rightSeats.keys()
			reversedRightSeats.invert()
			for seat in reversedRightSeats:
				if not rightSeats[seat]:
					new_player.position = seat
					rightSeats[seat] = new_player
					break
	else:
		var availableSeat = false
		for seat in rightSeats:
			if not rightSeats[seat]:
				new_player.position = seat
				rightSeats[seat] = new_player
				availableSeat = true
				break
		if not availableSeat:
			var reversedLeftSeats = leftSeats.keys()
			reversedLeftSeats.invert()
			for seat in reversedLeftSeats:
				if not leftSeats[seat]:
					new_player.position = seat
					leftSeats[seat] = new_player
					break
					
	get_tree().get_root().get_node("Board").add_child(new_player)
	new_player.add_to_group("Players")
	playerOrder.append(new_player)

remote func removePlayer(player_id, info):
	for node in get_tree().get_root().get_node("Board").get_children():
		if node.get_name() == info.name:
			
			if node.position in rightSeats:
				rightSeats[node.position] = null
				for i in range(0, rightSeats.keys().size() - 1):
					if rightSeats[rightSeats.keys()[i]] != null:
						continue
					if rightSeats[rightSeats.keys()[i + 1]] == null:
						break
					rightSeats[rightSeats.keys()[i]] = rightSeats[rightSeats.keys()[i + 1]]
					rightSeats[rightSeats.keys()[i]].position = rightSeats.keys()[i]
					rightSeats[rightSeats.keys()[i]].reorient()
					rightSeats[rightSeats.keys()[i + 1]] = null
				
			elif node.position in leftSeats:
				leftSeats[node.position] = null
				for i in range(0, leftSeats.keys().size() - 1):
					if leftSeats[leftSeats.keys()[i]] != null:
						continue	
					if leftSeats[leftSeats.keys()[i + 1]] == null:
						break
					leftSeats[leftSeats.keys()[i]] = leftSeats[leftSeats.keys()[i + 1]]
					leftSeats[leftSeats.keys()[i]].position = leftSeats.keys()[i]
					leftSeats[leftSeats.keys()[i]].reorient()
					leftSeats[leftSeats.keys()[i + 1]] = null
					
			playerOrder.erase(node)
			node.queue_free()
	players.erase(player_id)
		

func updateGame(cardsOrVals, ignoreSelf, ignoreServer):
	if cardsOrVals == "cards":
		rpc('updateGameState', gamestate, ignoreSelf, ignoreServer)
		gamestate = {}
	elif cardsOrVals == "vals":
		rpc('updateGameValues', gamestateValues)
	
remotesync func updateGameState(state, ignoreSelf, ignoreServer):
	if ignoreServer and get_tree().is_network_server():
		return
	for participant in state:
		if ignoreSelf and participant == self_data.name:
			continue
		var playerNode = get_tree().get_root().get_node("Board").get_node(participant)
		for area in state[participant]:
			var areaNode = playerNode.find_node(area)
			if area == "Discard" or area == "Active":
				for child in areaNode.get_children():
					areaNode.remove_child(child)
					child.queue_free()
			for card in state[participant][area]:
				if typeof(card) == TYPE_INT:
					if areaNode.get_child_count() != 0:
						var cardToDelete = areaNode.get_children()[0]
						areaNode.remove_child(cardToDelete)
						cardToDelete.queue_free()
					continue
				var faceUp = false
				var cardInstance = load("res://Cards/" + card + ".tscn")
				var newCard = cardInstance.instance()
				newCard.set_network_master(playerNode.get_network_master())
				if area != "Discard":
					newCard.position.x += 180 * areaNode.get_child_count()
				if area == "Active" or area == "Discard":
					faceUp = true
					if area == "Active":
						newMinionsPlayed.append(newCard)
				if area == "Keeps" and (areaNode.get_child_count() == 2 or areaNode.get_child_count() == 3):
					faceUp = true
				elif area == "Discards":
					faceUp = true
				areaNode.add_child(newCard)
				newCard.minionOwner = playerNode
				if not newCard.is_network_master():
					if not faceUp:
						newCard.get_node("Cardback").visible = true

remotesync func updatePlays(plays):
	for participant in plays:
		var playerNode = get_tree().get_root().get_node("Board").get_node(participant)
		if playerNode.is_network_master():
			continue
		var cardInstance = load("res://Cards/" + plays[participant] + ".tscn")
		var newCard = cardInstance.instance()
		newCard.set_network_master(playerNode.get_network_master())
		playerNode.find_node("Active").add_child(newCard)
		newCard.minionOwner = playerNode
		newMinionsPlayed.append(newCard)
		var playerHand = playerNode.find_node("Hand")
		for card in playerHand.get_children():
			if card.idName == plays[participant]:
				playerHand.remove_child(card)
				card.queue_free()
				break
				
	
remotesync func updateGameValues(state):
	for participant in state:
		var playerNode = get_tree().get_root().get_node("Board").get_node(participant)
		if Global.getActiveMinion(playerNode):
			var activeMinion = Global.getActiveMinion(playerNode)
			activeMinion.attack = state[participant]["ActiveAttack"]
			activeMinion.get_node("AttackLabel").update()
			activeMinion.get_node("AttackLabel2").update()
		playerNode.find_node("Lives").text = str(state[participant]["Lives"])
		if state[participant]["Eliminated"]:
			playerNode.find_node("Eliminated").visible = true
			if participant == self_data.name:
				clickableHand = false

func updateGamestateArray():
	for playerNode in get_tree().get_nodes_in_group("Players"):
		if not Global.getActiveMinion(playerNode):
			gamestate[playerNode.name] = {}
			gamestate[playerNode.name]["Active"] = [-1]
		else:
			gamestate[playerNode.name] = {}
			gamestate[playerNode.name]["Active"] = [Global.getActiveMinion(playerNode).idName]
		var DiscardArray = []
		var discards = Global.getDiscard(playerNode)
		for card in discards:
			DiscardArray.append(card.idName)
		DiscardArray.invert()
		gamestate[playerNode.name]["Discard"] = DiscardArray
		
		
		var hand = Global.getHand(playerNode)
#		if hand != null:
#			print(hand.size())

	
func callBlinds(bigBlind, smallBlind):
	rset_id(bigBlind.id, 'isBigBlind', true)
	rset_id(smallBlind.id, 'isSmallBlind', true)
	rset('big', bigBlind.name)
	rset('small', smallBlind.name)
	rpc('enterBlinds')
	
	
remotesync func enterBlinds():
	if isBigBlind:
		var currMoney = self_data.money
		var bet = Global.blindAmount
		self_data.money -= bet
		if Global.blindAmount > currMoney:
			bet = currMoney
			self_data.money = 0
		
		rset('lastBetter', self_data.name)
		rset('currentBet', Global.blindAmount)
		rpc('forwardBet', self_data.name, bet)
		return
		
	if isSmallBlind:
		var currMoney = self_data.money
		var bet = int(Global.blindAmount/2)
		self_data.money -= bet
		if Global.blindAmount > currMoney:
			bet = currMoney
			self_data.money = 0
		
		rpc('forwardBet', self_data.name, bet)
		return
		
func sendRaise(amount):
	var bettingPlayer = get_tree().get_root().get_node("Board").get_node(self_data.name)
	var moneyToSubtract = amount - int(bettingPlayer.find_node("BetAmount").text)
	if moneyToSubtract < 0:
		moneyToSubtract = 0
	self_data.money -= moneyToSubtract
	checksAllAround = false
	rset('lastBetter', self_data.name)
	rset('currentBet', amount)
	rset('raisedThisRound', true)
	rpc('forwardBet', self_data.name, amount)

func sendCall():
	var bettingPlayer = get_tree().get_root().get_node("Board").get_node(self_data.name)
	var totalMoney = self_data.money + int(bettingPlayer.find_node("BetAmount").text)
	
	if currentBet > totalMoney:
		rpc('forwardBet', self_data.name, totalMoney)
		self_data.money = 0
		return
		
	var moneyToSubtract = currentBet - int(bettingPlayer.find_node("BetAmount").text)
	if moneyToSubtract < 0:
		moneyToSubtract = 0
	
	if moneyToSubtract > self_data.money:	
		moneyToSubtract = self_data.money
	self_data.money -= moneyToSubtract
	
	rpc('forwardBet', self_data.name, currentBet)
	
func sendCheck():
	if isBigBlind and firstRound:
		rset('bigBlindCheckedFirstRound', true)
	rpc('forwardBet', self_data.name, 0)

func sendFold():
	if isBigBlind and firstRound:
		rset('bigBlindFoldedFirstRound', true)
	rpc('forwardFold', self_data.name)
	
	
remotesync func forwardBet(playerName, amount):
	var bettingPlayer = get_tree().get_root().get_node("Board").get_node(playerName)
	var moneyToSubtract = amount - int(bettingPlayer.find_node("BetAmount").text)
	if moneyToSubtract < 0:
		moneyToSubtract = 0
	bettingPlayer.find_node("Money").text = str(int(bettingPlayer.find_node("Money").text) - moneyToSubtract)
	bettingPlayer.find_node("BetAmount").text = str(amount)
	if amount == 0:	
		if not (big == bettingPlayer.name and firstRound):
			bettingPlayer.find_node("BetAmount").text = "Check"
		else:
			bettingPlayer.find_node("BetAmount").text = str(Global.blindAmount)
	bettingPlayer.find_node("BetAmount").visible = true

remotesync func forwardFold(playerName):
	var foldingPlayer = get_tree().get_root().get_node("Board").get_node(playerName)
	foldingPlayer.get_node("Eliminated").visible = true
	foldingPlayer.find_node("BetAmount").visible = false
	if get_tree().is_network_server():
		activePlayers.erase(foldingPlayer)
		justFolded = true

func sendBetActions():
	var i = 2 % activePlayers.size()
	if not firstRound:
		i = 0
		rset('currentBet', 0)
	checksAllAround = true
	
	var iterations = 0
	while true:
		if activePlayers.size() == 1:
			winningPlayers.append(activePlayers[0])
			consolidatePot()
			yield(get_tree().create_timer(1), "timeout")
			get_tree().get_root().get_node("Board").endCurrentRound()
			return
		if lastBetter != null:
			if lastBetter == activePlayers[i].name and currentBet > 0:
				if firstRound and activePlayers[i].name == big and not raisedThisRound:
					pass
				else:
					break
		if checksAllAround and not firstRound and iterations > 0:
			break
		if bigBlindCheckedFirstRound:
			bigBlindCheckedFirstRound = false
			break
		if bigBlindFoldedFirstRound:
			bigBlindFoldedFirstRound = false
			break
		rpc_id(activePlayers[i].id, 'bettingPhase')
		yield(self, "turnOver")
		if not justFolded:
			i += 1
		justFolded = false
		if i == activePlayers.size():
			i = 0
			iterations += 1
	consolidatePot()
	
	if phase == "preflop":
		sendFlop()
		rset('phase', "flop")
	elif phase == "flop":
		sendTurn()
		rset('phase', "turn")
	elif phase == "turn":
		sendRiver()
		rset('phase', "river")
	elif phase == "river":
		var remainingNames = []
		for remaining in activePlayers:
			remainingNames.append(remaining.name)
		rpc('prepareBattlePhase', remainingNames)
		rset('phase', "Battle")
	
	if firstRound:
		rset('firstRound', false)	
	return
	
func togglePots():
	rpc('togglePot')
	
remotesync func togglePot():
	var PotLabelNode = get_tree().get_root().get_node("Board").get_node("PotLabel")
	var PotAmountNode = get_tree().get_root().get_node("Board").get_node("PotAmount")
	
#	if PotLabelNode.visible:
#		PotLabelNode.visible = false
#	if PotAmountNode.visible:
#		PotAmountNode.visible = false
	if not PotLabelNode.visible:
		PotLabelNode.visible = true
	if not PotAmountNode.visible:
		PotAmountNode.visible = true


	
func consolidatePot():
	for playerNode in get_tree().get_nodes_in_group("Players"):
		var playerBet = playerNode.find_node("BetAmount")
		if not playerBet.text == "Check":
			currentPot += int(playerBet.text)
	rset('currentPot', currentPot)
	rpc('updatePot')
		
remotesync func updatePot():
	for playerNode in get_tree().get_nodes_in_group("Players"):
		var playerBet = playerNode.find_node("BetAmount")
		playerBet.text = '0'
		playerBet.visible = false
	get_tree().get_root().get_node("Board").get_node("PotAmount").text = str(currentPot)
		
		
	
	
remotesync func endBet():
	emit_signal("turnOver")

#func serverEndBet(isServer, fold, check, call, raise, raiseAmount):
func serverEndBet(isServer):
	if isServer:
		emit_signal("turnOver")
	else:
		rpc_id(1, 'endBet')
	
remotesync func bettingPhase():
	var turnTimer = get_tree().get_root().get_node("Board").get_node("TurnTimer")
	turnTimer.turn = "Betting"
	turnTimer.wait_time = Global.turnTimer
	turnTimer.start()
	var betActionsNode = get_tree().get_root().get_node("Board").get_node("BetActions")
	if firstRound and isBigBlind and not raisedThisRound:
		betActionsNode.get_node("Call").visible = false
		betActionsNode.get_node("Check").rect_position.x += 150
		betActionsNode.get_node("Raise").rect_position.x += 160
	elif firstRound:
		betActionsNode.get_node("Check").visible = false
		betActionsNode.get_node("Raise").rect_position.x += 170
	elif currentBet == 0:
		betActionsNode.get_node("Call").visible = false
		betActionsNode.get_node("Check").rect_position.x += 150
		betActionsNode.get_node("Raise").rect_position.x += 160
	else:
		betActionsNode.get_node("Check").visible = false
		betActionsNode.get_node("Raise").rect_position.x += 170
	betActionsNode.visible = true

func sendPreflop():
	for remainingPlayer in activePlayers:
		var preflopToSend = []
		for _i in range(0, 2):
			var card = Global.deck.pop_front()
			preflopToSend.append(card[0])
		rpc_id(remainingPlayer.id, 'drawPreflop', preflopToSend)
		gamestate[remainingPlayer.name] = {}
		gamestate[remainingPlayer.name]["Keeps"] = preflopToSend
	updateGame("cards", true, false)
	
remotesync func drawPreflop(preflop):
	var KeepsNode = Global.getMyPlayer().find_node("Keeps")
	var card = load("res://Cards/" + preflop[0] + ".tscn")
	var card1 = card.instance()
	card1.position.x += 180 * KeepsNode.get_child_count()
	KeepsNode.add_child(card1)
	
	card = load("res://Cards/" + preflop[1] + ".tscn")
	var card2 = card.instance()
	card2.position.x += 180 * KeepsNode.get_child_count()
	KeepsNode.add_child(card2)
	
	Network.gamestate[self_data.name] = {}
	Network.gamestate[self_data.name]["Keeps"] = [card1.idName, card2.idName]
		
func sendFlop():
	confirmedFlops = 0
	for remainingPlayer in activePlayers:
		var flopToSend = []
		for _i in range(0, 3):
			var card = Global.deck.pop_front()
			flopToSend.append(card[0])
		rpc_id(remainingPlayer.id, 'flopActions', flopToSend)
		
remotesync func flopActions(flop):
	var turnTimer = get_tree().get_root().get_node("Board").get_node("TurnTimer")
	turnTimer.turn = "Mulling"
	turnTimer.wait_time = Global.turnTimer
	turnTimer.start()
	
	var flopActions = get_tree().get_root().get_node("Board").get_node("FlopScreen")
	
	var card1 = load("res://Cards/" + flop[0] + ".tscn").instance()
	flopActions.get_node("Flop1").add_child(card1)
	flopActions.flop1 = card1.idName
	
	var card2 = load("res://Cards/" + flop[1] + ".tscn").instance()
	flopActions.get_node("Flop2").add_child(card2)
	flopActions.flop2 = card2.idName
	
	var card3 = load("res://Cards/" + flop[2] + ".tscn").instance()
	flopActions.get_node("Flop3").add_child(card3)
	flopActions.flop3 = card3.idName
	
	flopActions.visible = true
	
func sendFlopToServer(playerName, Keeps, Discards):
	rpc_id(1, 'receiveFlop', playerName, Keeps, Discards)
	
remotesync func receiveFlop(playerName, Keeps, Discards):
	gamestate[playerName] = {}
	gamestate[playerName]["Keeps"] = Keeps
	gamestate[playerName]["Discards"] = Discards
	
	confirmedFlops += 1
	if confirmedFlops >= activePlayers.size():
		updateGame("cards", true, false)
		sendBetActions()

func sendTurn():
	confirmedTurns = 0
	for remainingPlayer in activePlayers:
		var turnToSend = Global.deck.pop_front()[0]
		rpc_id(remainingPlayer.id, 'turnActions', turnToSend)
	
remotesync func turnActions(turn):
	var turnTimer = get_tree().get_root().get_node("Board").get_node("TurnTimer")
	turnTimer.turn = "Mulling"
	turnTimer.wait_time = Global.turnTimer
	turnTimer.start()
	
	var turnActions = get_tree().get_root().get_node("Board").get_node("RiverTurn")
		
	var card = load("res://Cards/" + turn + ".tscn").instance()
	turnActions.get_node("Card").add_child(card)
	turnActions.cardname = card.idName
	
	turnActions.visible = true
	
func sendTurnToServer(playerName, Keeps, Discards):
	rpc_id(1, 'receiveTurn', playerName, Keeps, Discards)
	
remotesync func receiveTurn(playerName, Keeps, Discards):
	gamestate[playerName] = {}
	gamestate[playerName]["Keeps"] = Keeps
	gamestate[playerName]["Discards"] = Discards
	
	confirmedTurns += 1
	if confirmedTurns >= activePlayers.size():
		updateGame("cards", true, false)
		sendBetActions()


func sendRiver():
	confirmedRivers = 0
	for remainingPlayer in activePlayers:
		var riverToSend = Global.deck.pop_front()[0]
		rpc_id(remainingPlayer.id, 'riverActions', riverToSend)
	
remotesync func riverActions(river):
	var turnTimer = get_tree().get_root().get_node("Board").get_node("TurnTimer")
	turnTimer.turn = "Mulling"
	turnTimer.wait_time = Global.turnTimer
	turnTimer.start()
	
	var riverActions = get_tree().get_root().get_node("Board").get_node("RiverTurn")
		
	var card = load("res://Cards/" + river + ".tscn").instance()
	riverActions.get_node("Card").add_child(card)
	riverActions.cardname = card.idName
	
	riverActions.visible = true
	
func sendRiverToServer(playerName, Keeps, Discards):
	rpc_id(1, 'receiveRiver', playerName, Keeps, Discards)
	
remotesync func receiveRiver(playerName, Keeps, Discards):
	gamestate[playerName] = {}
	gamestate[playerName]["Keeps"] = Keeps
	gamestate[playerName]["Discards"] = Discards
	
	confirmedRivers += 1
	if confirmedRivers >= activePlayers.size():
		updateGame("cards", true, false)
		sendBetActions()



#BATTLE PHASE FUNCS

remotesync func prepareBattlePhase(remaining):
	for participant in get_tree().get_nodes_in_group("Players"):
		if participant.name in remaining:
			participant.transitionHand()
		else:
			participant.resetBettingArea()
	for playerName in remaining:
		gamestateValues[playerName] = {
			'Lives': 3,
			'ActiveAttack': 0,
			'Eliminated': false
		}
	if get_tree().is_network_server():
		get_tree().get_root().get_node("Board").battlePhase()
		
func determineTargeting(remainingPlayers):
	for i in range(0, remainingPlayers.size()):
		if i == 0:
			remainingPlayers[i].targetedBy = remainingPlayers[remainingPlayers.size() - 1]
		else:
			remainingPlayers[i].targetedBy = remainingPlayers[i - 1]
		if i == remainingPlayers.size() - 1:
			remainingPlayers[i].targeting = remainingPlayers[0]
		else:
			remainingPlayers[i].targeting = remainingPlayers[i + 1]

func playMinions():
	determineTargeting(activePlayers)
	
	self.confirmedPlays = 0
	
	playsThisTurn = {}
	newMinionsPlayed = []
	for participant in activePlayers:
		rpc_id(participant.id, 'playMinion')
		
	yield(self, "continueGameSequence")
	
	determineTargeting(activePlayers)
	for participant in activePlayers:
		participant.determineAdjacentMinions()
	
	for participant in activePlayers:
		var activeMinion = Global.getActiveMinion(participant)
		activeMinion.activateBox()
		gamestateValues[participant.name]["ActiveAttack"] = activeMinion.attack
	
	
	
	yield(get_tree().create_timer(1), "timeout")
#--------------------Trigger phase-------------------------------------------
		#trigger phase and update Labels and status
	for minion in newMinionsPlayed:
		print(minion.idName)
		minion.trigger()
		minion.activateBox()
		gamestateValues[minion.minionOwner.name]["ActiveAttack"] = minion.attack
		updateGamestateArray()
		updateGame("cards", false, true)
		updateGame("vals", true, false)
		yield(get_tree().create_timer(0.5), "timeout")
	
	for participant in activePlayers:
		var activeMinion = Global.getActiveMinion(participant)
		activeMinion.activateBox()
		gamestateValues[participant.name]["ActiveAttack"] = activeMinion.attack
	
	updateGame("vals", true, false)
	
	yield(get_tree().create_timer(1), "timeout")
	
#-----------------Attack phase------------------------------------------

	emit_signal("attackPhase")

remotesync func playMinion():
	var myPlayer = Global.getMyPlayer()
	if Global.hasActiveMinion(myPlayer):
		rpc_id(1, 'confirmPlay')
		return
	#send some message
	clickableHand = true	

func attackPhase():
	Global.playersToDamage = []
	var deathsFromAttacks = []
	
	for participant in activePlayers:
		var activeMinion = Global.getActiveMinion(participant)
		deathsFromAttacks += activeMinion.doAttack()
	
	#death discards resolve
	for death in deathsFromAttacks:
		var killedMinion = death[0]
		var murderer = death[1]
		if murderer.has_method("devour"):
			murderer.devour(killedMinion)
		else:
			Global.killMinion(killedMinion, murderer)
	
	updateGamestateArray()
	updateGame("cards", false, true)
	
	#last laugh phase
	for death in deathsFromAttacks:
		var killedMinion = death[0]
		if killedMinion.has_method("lastLaugh"):
			killedMinion.lastLaugh()
	
	updateGamestateArray()
	updateGame("cards", false, true)
	
	#update statuses and health
	for participant in activePlayers:
		if not participant in Global.playersToDamage:
			if Global.hasActiveMinion(participant):
				participant.takeDamage(-1)
				gamestateValues[participant.name]["Lives"] = participant.health
				var minion = Global.getActiveMinion(participant)
				minion.activateBox()
				gamestateValues[participant.name]["ActiveAttack"] = minion.attack
			else:
				continue
		else:
			participant.takeDamage(1)
			gamestateValues[participant.name]["Lives"] = participant.health
			
	#find eliminated players
	var newlyDead = []
	for participant in activePlayers:
		#if player is at 0 health
		if participant.health <= 0:
			newlyDead.append(participant)
			participant.get_node("Eliminated").visible = true
			continue	
		#if player is out of steam
		if Global.isHandEmpty(participant) and not Global.hasActiveMinion(participant):
			newlyDead.append(participant)
			participant.get_node("Eliminated").visible = true
	
	#remove players from game
	if newlyDead.size() > 0:
		for dead in newlyDead:
			gamestateValues[dead.name]["Eliminated"] = true
			activePlayers.erase(dead)
	
	
	updateGame("vals", true, false)
	
	#check for win
	if activePlayers.size() <= 1:
		gameOver = true
		if activePlayers.size() == 1:
			winningPlayers.append(activePlayers[0])
			#$Label.text = remainingPlayers[0].playerName + " wins!"
		else:
			for participant in newlyDead:
				winningPlayers.append(participant)
			#$Label.text = "pot split!"
	
	for participant in activePlayers:
		var activeMinion = Global.getActiveMinion(participant)
		if activeMinion != null:
			if activeMinion.has_method("endRound"):
				activeMinion.endRound()
				gamestateValues[participant.name]["ActiveAttack"] = activeMinion.attack

func distributeMoney():
	var moneyDict = {}
	for winner in winningPlayers:
		var currentMoney = int(winner.find_node("Money").text)
		currentMoney += currentPot/winningPlayers.size()
		moneyDict[winner.name] = currentMoney
	rpc('updateMoney', moneyDict)
	
remotesync func updateMoney(moneyDict):
	for winner in moneyDict:
		var winnerNode = get_tree().get_root().get_node("Board").get_node(winner)
		winnerNode.find_node("Money").text = str(moneyDict[winner])
		if winner == self_data.name:
			self_data.money = moneyDict[winner]
	get_tree().get_root().get_node("Board").get_node("PotAmount").text = '0'
		
	
remotesync func confirmPlay():
	self.confirmedPlays += 1
	
func sendPlayToServer(playerName, play):
	clickableHand = false
	rpc_id(1, 'receivePlay', playerName, play)
	
remotesync func receivePlay(playerName, play):
	playsThisTurn[playerName] = play
	
	#check if its server and add to newMinionsPlayed
	if playerName == self_data.name:
		var myPlayer = Global.getMyPlayer()
		newMinionsPlayed.append(myPlayer.find_node("Active").get_children()[0])
		
	confirmPlay()


func setConfirmedPlays(newVal):
	confirmedPlays = newVal
	if newVal >= activePlayers.size():
		rpc('updatePlays', playsThisTurn)
		emit_signal("continueGameSequence")
	
func getConfirmedPlays():
	return confirmedPlays
	
func resetAllPlayers():
	rpc('sendResets')
	
remotesync func sendResets():
	for participant in get_tree().get_nodes_in_group("Players"):
		participant.resetAll()
		
func resetValues():
	gamestate = {}
	gamestateValues = {}
	rset('phase', "preflop")
	rset('firstRound', true)
	rset('isBigBlind', false)
	rset('isSmallBlind', false)
	rset('big', null)
	rset('small', null)
	rset('currentPot', 0)
	rset('currentBet', Global.blindAmount)
	rset('lastBetter', null)
	rset('firstBetter', null)
	rset('raisedThisRound', false)
	rset('bigBlindCheckedFirstRound', false)
	rset('bigBlindFoldedFirstRound', false)

	justFolded = false
	checksAllAround = true
	confirmedFlops = 0
	confirmedTurns = 0
	confirmedRivers = 0
	self.confirmedPlays = 0

	clickableHand = false
	newMinionsPlayed.clear()
	winningPlayers.clear()
	gameOver = false

	activePlayers = playerOrder
	
	
