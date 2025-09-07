extends RigidBody2D


func _ready() -> void:
	await get_tree().create_timer(10).timeout
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("segment"):
		$chain.play()
		body.queue_free()
