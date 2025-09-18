extends CanvasLayer

var menu_in = false

func _ready() -> void:
	$ColorRect.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if menu_in:
			menu_in = false
			$ColorRect.visible = false
			$"../CanvasLayer".layer = 1
		else:
			menu_in = true
			$ColorRect.visible = true
			$"../CanvasLayer".layer = 0
			
