extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.playerCount = 2
	Global.gamesToSimulate = 1000
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Increment Player Count
func _on_Arrow_pressed():
	if Global.playerCount == 4:
		Global.playerCount = 2
	else:
		Global.playerCount += 1
	$Number.text = str(Global.playerCount)
	pass # Replace with function body.

# Total Game Count
func _on_GamesInput_text_changed(new_text):
	if new_text.length() == 0:
		return
	elif new_text.is_valid_integer():
		if(int(new_text) >= 10000):
			new_text = "10000"
			$GamesInput.text = new_text
		Global.gamesToSimulate = int(new_text)
	else:
		$GamesInput.editable = false
		$GamesInput.text = "INVALID"
		yield(get_tree().create_timer(0.5), "timeout")
		$GamesInput.text = ""
		$GamesInput.editable = true
