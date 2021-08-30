extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func selectCard():
	var menuNode = get_parent().get_parent()
	if menuNode.hand.size() == 5:
		return
	var slot = menuNode.get_node(str(menuNode.hand.size() + 1))
	var path = "res://Assets/CardAssets/" + self.name + ".png"
	slot.texture = load(path)
	menuNode.hand.append(self.name)

func _on_Card_Selected():
	selectCard()
	
