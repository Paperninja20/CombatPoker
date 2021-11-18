extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player = preload("res://MultiplayerPlayer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var mainPlayer = player.instance()
	var playerInfo = Network.self_data
	mainPlayer.get_node("PlayerTag").text = playerInfo.name
	mainPlayer.get_node("Money").text = "$" + str(playerInfo.money)
	mainPlayer.scale = Vector2(1, 1)
	mainPlayer.position = Vector2(960, 900)
	get_tree().get_root().add_child(mainPlayer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
