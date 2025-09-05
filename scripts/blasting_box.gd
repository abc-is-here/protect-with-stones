extends RigidBody2D

@export var explosion_particles: PackedScene


func blast():
	var particle = explosion_particles.instantiate()
	particle.position = global_position
	particle.rotation = global_rotation
	particle.emitting = true
	
	get_tree().current_scene.add_child(particle)
	
	queue_free()

func _on_kill_area_body_entered(body: Node2D) -> void:
	pass


func _on_stone_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("stone"):
		body.queue_free()
		blast()
