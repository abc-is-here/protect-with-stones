extends Control

func _process(delta: float) -> void:
	$ProgressBar.value = Global.stamina
