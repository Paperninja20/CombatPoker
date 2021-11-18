extends Node


const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 1909
const MAX_PLAYERS = 6

var players = {}
var self_data = {name = '', money = 500}

func _ready():
	pass
	
func CreateLobby(player_nickname):
	self_data.name = player_nickname
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	
	peer.connect("peer_connected", self, "_Peer_Connected")
	peer.connect("peer_disconnected", self, "_Peer_Disconnected")
	
func JoinLobby(player_nickname):
	self_data.name = player_nickname
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	players[get_tree().get_network_unique_id()] = self_data
	
func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	players.erase(player_id)
	
	

