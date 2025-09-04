extends Control

func _process(_delta: float) -> void:
	$ProgressBar.value = Global.stamina
