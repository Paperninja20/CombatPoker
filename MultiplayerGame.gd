extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player = preload("res://MultiplayerPlayer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var mainPlayer = player.instance()
	var playerInfo = Network.self_data
	mainPlayer.name = playerInfo.name + "#" + str(playerInfo.id)
	mainPlayer.id = playerInfo.id
	mainPlayer.set_network_master(playerInfo.id, true)
	mainPlayer.get_node("PlayerTag").text = playerInfo.name + "#" + str(playerInfo.id)
	mainPlayer.get_node("BettingPhase/Money").text = str(playerInfo.money)
	mainPlayer.get_node("BettingPhase/BetAmount").rect_scale = Vector2(0.83,0.83)
	mainPlayer.get_node("BettingPhase/BetAmount").rect_position.x += 15.81
	mainPlayer.get_node("BettingPhase/BetAmount").rect_position.y += 6.29
	mainPlayer.get_node("BettingPhase/Capsule").scale *= .83
	mainPlayer.scale = Vector2(.9, .9)
	mainPlayer.position = Vector2(960, 920)
	get_tree().get_root().get_node("Board").add_child(mainPlayer)
	mainPlayer.add_to_group("Players")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
