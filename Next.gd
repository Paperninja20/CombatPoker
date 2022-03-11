extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var i = 1
func _on_Next_pressed():
	i = i + 1
	var pic = get_parent().get_node("Picture")
	pic.texture = load("res://Tutorial Pictures//" + String(i) + ".png")
