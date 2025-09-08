extends RigidBody2D


func _ready() -> void:
	await get_tree().create_timer(10).timeout
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("segment"):
		$chain.play()
		var chain = body.get_parent()
		body.queue_free()
		await get_tree().create_timer(0.8).timeout
		
		for child in chain.get_children():
			if child.name != "box":
				child.queue_free()
