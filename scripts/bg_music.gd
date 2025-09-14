extends AudioStreamPlayer

func _process(_delta: float) -> void:
	if Global.is_slowed:
		pitch_scale = 0.83
	else:
		pitch_scale = 1.0
