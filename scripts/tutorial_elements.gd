extends Node2D


func _on_flag_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Label5.visible = true
