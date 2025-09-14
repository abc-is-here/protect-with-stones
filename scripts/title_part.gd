extends Node2D

@export var letter: String

func _process(_delta: float) -> void:
	$box/Label.text = letter
