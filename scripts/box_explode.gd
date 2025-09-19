extends RigidBody2D

@export var explosion_particles: PackedScene
@export var blast_collision_area: PackedScene

var is_frozen = false
var is_burning = false
var lightning_hit = false

var exp_queue = false

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
	if (body.is_in_group("stone") or body.is_in_group("bullet")):
		body.queue_free()
		$Sprite2D.play("blink")
		$Sprite2D.speed_scale+=0.5
		await get_tree().create_timer(0.3).timeout
		
		if is_frozen:
			exp_queue = true
		else:
			blast()

func freeze(duration: float = 4.0) -> void:
	if is_frozen: return
	is_frozen = true
	$TntBoxIce.visible = true
	#fire.emitting = false
	#velocity = Vector2.ZERO
	await get_tree().create_timer(duration).timeout
	is_frozen = false
	$TntBoxIce.visible = false
	if exp_queue:
		exp_queue = false
		blast()

func burn(duration: float = 4.0) -> void:
	#if on_fire: return
	#on_fire = true
	#frozen = false
	#frozen_ice.visible = false
	#fire.emitting = true
#
	#speed_multiplier = 2.0
#
	#for i in range(duration):
		#if not on_fire: break
		#decrease_health(2)
		#await get_tree().create_timer(1.0).timeout
#
	#speed_multiplier = 1.0
	#fire.emitting = false
	#on_fire = false
	pass

func lightning_strike(duration: float = 3.0) -> void:
	#if lightning: return
	#lightning = true
	#decrease_health(5)
	#speed_multiplier = 0.5
	#await get_tree().create_timer(duration).timeout
	#speed_multiplier = 1.0
	#lightning = false
	pass
