extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var myCard
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RevealButton3_pressed():
	disabled = true
	get_parent().get_parent().swapHidden(myCard, self.name)
	pass # Replace with function body.
