extends RigidBody2D

var pulled_enemies: Array = []
@export var lifetime: float = 5.0
@export var pull_strength: float = 400.0

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	for enemy in pulled_enemies:
		if enemy and enemy.is_inside_tree():
			if enemy.has_method("apply_vacuum_pull"):
				enemy.apply_vacuum_pull(global_position, pull_strength, delta)
				print("Pulling", enemy)

#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.is_in_group("enemy"):
		#if not pulled_enemies.has(body):
			#pulled_enemies.append(body)
#
#func _on_area_2d_body_exited(body: Node2D) -> void:
	#if body.is_in_group("enemy"):
		#pulled_enemies.erase(body)


func _on_detect_enemy_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if not pulled_enemies.has(body):
			pulled_enemies.append(body)
	print("Enemy entered:", body)


func _on_detect_enemy_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		pulled_enemies.erase(body)
