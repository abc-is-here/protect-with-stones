extends Node2D

var dir = 1
var speed = 800
@export var Destroyparticles: PackedScene

func _physics_process(delta: float) -> void:
	position.x += speed * delta * dir
	rotation = 0 if dir == -1 else PI


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.decrease_healh(5)
		queue_free()
	if body.is_in_group("blast_box"):
		body.blast()
	if body.is_in_group("ground"):
		queue_free()
	
	var particle = Destroyparticles.instantiate()
	particle.position = global_position
	particle.rotation = rotation
	particle.emitting = true
	get_tree().current_scene.add_child(particle)


func shoot_bullets(d):
	dir = d
	await get_tree().create_timer(5).timeout
	queue_free()

func set_dir(d):
	dir = d
	return dir
