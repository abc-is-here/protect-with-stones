extends RigidBody2D

@export var dust_particles: PackedScene
var impact_thresh := 10.0
var cooldown := 0.15
var can_emit := true

@onready var ray_casts: Array[RayCast2D] = [
	$RayCastBottom,
	$RayCastTop,
	$RayCastRight,
	$RayCastLeft
]

@onready var markers: Array[Marker2D] = [
	$MarkerBottom,
	$MarkerTop,
	$MarkerRight,
	$MarkerLeft
]

func _physics_process(_delta: float) -> void:
	if linear_velocity.length() < impact_thresh:
		return
	
	for i in ray_casts.size():
		var ray: RayCast2D = ray_casts[i]
		if ray.is_colliding() and can_emit:
			var collider = ray.get_collider()
			if collider and collider.is_in_group("ground"):
				spawn_dust(markers[i].global_position)
				start_cooldown()

func spawn_dust(pos: Vector2) -> void:
	if not dust_particles:
		return
	
	var dust := dust_particles.instantiate() as CPUParticles2D
	dust.global_position = pos
	get_tree().current_scene.add_child(dust)
	dust.restart()
	
	await get_tree().create_timer(dust.lifetime + 0.2).timeout
	if is_instance_valid(dust):
		dust.queue_free()

func start_cooldown() -> void:
	can_emit = false
	await get_tree().create_timer(cooldown).timeout
	can_emit = true

func _on_sound_hit_body_entered(_body: Node2D) -> void:
	$AudioStreamPlayer2D.play()
