extends RigidBody2D


func _ready() -> void:
	await get_tree().create_timer(5).timeout
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body and body.is_in_group("segment"):
		$chain.play()
		var chain = body.get_parent()
		var children = chain.get_children()
		var hit_index = children.find(body)

		var to_free = []
		for i in range(hit_index + 1, children.size()):
			if children[i].is_in_group("segment"):
				to_free.append(children[i])

		body.queue_free()

		await get_tree().create_timer(0.2).timeout
		for node in to_free:
			if node and node.is_inside_tree():
				node.queue_free()
	
	if body and body.is_in_group("enemy"):
		body.burn()
		queue_free()
