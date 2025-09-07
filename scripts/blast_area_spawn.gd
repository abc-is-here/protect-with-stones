extends Node2D

func _ready() -> void:
	await  get_tree().create_timer(0.7).timeout
	queue_free()

func _on_detect_char_area_entered(area: Area2D) -> void:
	$AudioStreamPlayer2D.play()
	var parent = area.get_parent()
	if parent.is_in_group("enemy"):
		parent.kill()
	if parent.is_in_group("player"):
		parent.decrease_healh(50)
