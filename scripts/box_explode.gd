extends RigidBody2D

@export var explosion_particles: PackedScene
@export var blast_collision_area: PackedScene


func blast():
	if explosion_particles:
		var particle = explosion_particles.instantiate()
		particle.position = global_position
		particle.rotation = global_rotation
		particle.emitting = true
		
		get_tree().current_scene.add_child(particle)
	
	if blast_collision_area:
		var blast_col = blast_collision_area.instantiate()
		blast_col.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", blast_col)
	
	queue_free()


func _on_stone_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("stone"):
		body.queue_free()
		$Sprite2D.play("blink")
		$Sprite2D.speed_scale+=0.5
		await get_tree().create_timer(0.3).timeout
		
		blast()
