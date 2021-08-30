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
func openHandBuilder():
	get_tree().change_scene("res://HandBuilder.tscn")

func _on_EditButton1_pressed():
	Global.HandBuilding = int(self.name[-1])
	openHandBuilder()
