extends Node2D

@export var gravity: Vector2 = Vector2(0, 980)
@export var num_points: int = 50
@export var time_step: float = 0.07
@export var dot_radius: float = 3.0
@export var dot_color: Color = Color(1.0, 1.0, 1.0, 0.267)

var points: Array[Vector2] = []

func draw_path(start_pos: Vector2, velocity: Vector2) -> void:
	points.clear()
	var space_state = get_world_2d().direct_space_state
	var last_pos = start_pos
	
	for i in range(num_points):
		var t = i * time_step
		var world_pos = start_pos + velocity * t + 0.5 * gravity * t * t
		
		var query = PhysicsRayQueryParameters2D.create(last_pos, world_pos)
		var result = space_state.intersect_ray(query)
		
		if result.size() > 0:
			points.append(result.position)
			break
		
		points.append(world_pos)
		last_pos = world_pos
	
	queue_redraw()

func _draw():
	for p in points:
		draw_circle(to_local(p), dot_radius, dot_color)
