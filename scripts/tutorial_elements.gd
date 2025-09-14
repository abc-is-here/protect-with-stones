extends Node2D

@export var explosion_particles: PackedScene

func _process(_delta: float) -> void:
	if Global.stamina <= 3:
		$Label9.visible = true
	else:
		$Label9.visible = false

func _on_flag_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$flag/Label5.visible = true
		var particle = explosion_particles.instantiate()
		particle.position = $flag/flag.global_position
		particle.rotation = $flag/flag.global_rotation
		var confetti = particle.get_node("confetti")
		var confetti1 = particle.get_node("confetti2")
		var confetti2 = particle.get_node("confetti3")
		confetti.emitting = true
		confetti1.emitting = true
		confetti2.emitting = true
		$flag/win.play()
		
		get_tree().current_scene.add_child(particle)
