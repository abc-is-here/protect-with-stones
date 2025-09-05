extends RigidBody2D

@export var explosion_particles: PackedScene


func blast():
	$"../detect_char/CollisionShape2D".disabled = false
	if explosion_particles:
		var particle = explosion_particles.instantiate()
		particle.position = global_position
		particle.rotation = global_rotation
		particle.emitting = true
		
		get_tree().current_scene.add_child(particle)
	
	get_parent().on_box_blasted()
	
	queue_free()


func _on_stone_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("stone"):
		body.queue_free()
		$Sprite2D.play("blink")
		$Sprite2D.speed_scale+=0.5
		await get_tree().create_timer(0.3).timeout
		
		blast()
