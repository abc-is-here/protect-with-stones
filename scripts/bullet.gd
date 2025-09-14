extends Node2D

var dir = 1
var speed = 800

func _physics_process(delta: float) -> void:
	set_dir(dir)
	position.x += speed * delta * dir


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.decrease_healh(5)
		queue_free()
	if body.is_in_group("blast_box"):
		body.blast()
	if body.is_in_group("ground"):
		queue_free()

func shoot_bullets(d):
	dir = d
	await get_tree().create_timer(5).timeout
	queue_free()

func set_dir(d):
	dir = d
	return dir
