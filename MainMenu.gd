extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.playerCount = 2
	Global.gamesToSimulate = 100
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Arrow_pressed():
	if Global.playerCount == 4:
		Global.playerCount = 2
	else:
		Global.playerCount += 1
	$Number.text = str(Global.playerCount)
	pass # Replace with function body.



func _on_GamesInput_text_changed(new_text):
	if new_text.length() == 0:
		return
	if new_text.is_valid_float():
		Global.gamesToSimulate = int(new_text)
	else:
		$GamesInput.editable = false
		$GamesInput.text = "INVALID"
		yield(get_tree().create_timer(0.5), "timeout")
		$GamesInput.text = ""
		$GamesInput.editable = true
