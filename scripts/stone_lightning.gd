extends RigidBody2D

var is_on_ground = false

func _ready() -> void:
	$lightning_root/Sprite2D.visible = false
	await get_tree().create_timer(5).timeout
	

func _physics_process(delta: float) -> void:
	$lightning_root.rotation = -rotation

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


func _on_lightning_body_entered(body: Node2D) -> void:
	if body and body.is_in_group("enemy") and is_on_ground:
		body.decrease_health(20)


func _on_ground_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("ground") and not is_on_ground:
		is_on_ground = true
		$lightning_root/Sprite2D.visible = true
		$AnimationPlayer.play("lightning_strike")
		await get_tree().create_timer(0.1).timeout
		var lightning_area = $lightning_root/lightning
		for enemy in lightning_area.get_overlapping_bodies():
			if enemy.is_in_group("enemy"):
				enemy.decrease_health(20)

		await $AnimationPlayer.animation_finished
		$lightning_root/lightning/CollisionShape2D.disabled = true
		queue_free()
