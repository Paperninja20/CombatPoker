extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var keepDiscardNode

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_PlayerIcon_button_down():
	if is_network_master():
			return
	if Network.phase == "battle":
		keepDiscardNode = get_tree().get_root().get_node("Board").get_node("KeepsDiscards")
		keepDiscardNode.reset()
		var keepsNode = keepDiscardNode.get_node("Keeps")
		var discardsNode = keepDiscardNode.get_node("Discards")
		
		for keep in get_parent().keeps:
			var card = load("res://Cards/" + keep + ".tscn")
			var newCard = card.instance()
			newCard.position.x += 180 * keepsNode.get_child_count()
			keepsNode.add_child(newCard)
		
		for discard in get_parent().discards:
			var card = load("res://Cards/" + discard + ".tscn")
			var newCard = card.instance()
			newCard.position.x += 180 * discardsNode.get_child_count()
			discardsNode.add_child(newCard)
		keepDiscardNode.visible = true


func _on_PlayerIcon_button_up():
	if is_network_master():
			return
	keepDiscardNode = get_tree().get_root().get_node("Board").get_node("KeepsDiscards")
	keepDiscardNode.visible = false

