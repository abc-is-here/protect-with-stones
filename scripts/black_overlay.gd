extends CanvasLayer

var overlay = false

func _ready() -> void:
	$ColorRect.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if overlay:
			overlay = false
			$ColorRect.visible = false
			$"../CanvasLayer".layer = 1
		else:
			overlay = true
			$ColorRect.visible = true
			$"../CanvasLayer".layer = 0
			
