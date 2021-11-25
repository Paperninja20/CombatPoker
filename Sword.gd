extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	position = get_parent().find_node("Active").position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
##	look_at(get_global_mouse_position())
##	rotation_degrees += 90

func swordAttackAnimation(target):
	look_at(target.find_node("Active").global_position)
	rotation_degrees += 90
	$Tween.interpolate_property(self, "global_position", global_position, target.find_node("Active").global_position, 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT_IN)
	visible = true
	$Tween.start()
	yield($Tween, "tween_completed")
	visible = false
	position = get_parent().find_node("Active").position
	
