extends Node2D

func on_box_blasted() -> void:
	await get_tree().create_timer(0.7).timeout
	queue_free()

func _on_detect_char_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group("character"):
		parent.queue_free()
