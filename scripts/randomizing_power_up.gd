extends Area2D


func _process(delta: float) -> void:
	rotation+=5
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass
