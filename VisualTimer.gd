extends TextureProgress


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var timeLeft = get_parent().get_node("TurnTimer").time_left
	var percentLeft = float(timeLeft)/float(Global.turnTimer)
	value = 100 * percentLeft
	tint_progress = Color(1, 1 * percentLeft, 1 * percentLeft, 1)
