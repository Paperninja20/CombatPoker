extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func animate():
	$Tween.interpolate_property(self, "rect_position", Vector2(rect_position.x, rect_position.y), Vector2(rect_position.x, 1080), 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	rect_position.y = -253
	get_parent().visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
