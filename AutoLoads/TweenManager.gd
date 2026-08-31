extends Node



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func TweenProperty(object,property,value,duration,typeOfTween):
	var tween = create_tween()
	tween.tween_property(object,property,value,duration).set_trans(typeOfTween)
	
	return tween
