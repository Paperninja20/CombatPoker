extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(get_parent().get_parent().health)

func update():
	text = str(get_parent().get_parent().health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
