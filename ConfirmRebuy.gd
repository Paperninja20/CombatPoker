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


func _on_ConfirmRebuy_pressed():
	print("sending rebuy")
	visible = false
	get_parent().get_node("MoneyField").visible = false
	get_parent().get_node("No").visible = true
	get_parent().get_node("Yes").visible = true
	get_parent().get_parent().visible = false
	Network.sendRebuy(Network.self_data.name, int(get_parent().get_node("MoneyField").text))
	Network.self_data.money = int(get_parent().get_node("MoneyField").text)
	if get_tree().is_network_server():
		if not Global.autoStart:
			get_tree().get_root().get_node("Board").get_node("Start").visible = true
