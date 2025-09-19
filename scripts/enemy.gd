extends CharacterBody2D

const MIN_SPEED = 100
const RUN_SPEED = 150
const GRAVITY = 800.0

var base_speed := MIN_SPEED
var speed_multiplier := 1.0

var health = 100
var direction := 1
var stuck := false
var player_visible = false

var can_shoot = true
var is_shooting = false
var frozen = false
var on_fire = false
var near_vacuum = false
var lightning = false
var vacuum_force := Vector2.ZERO


@onready var rc_bottom_left: RayCast2D = $rc_bottom_left
@onready var rc_bottom_right: RayCast2D = $rc_bottom_right
@onready var eye_view_left: RayCast2D = $eye_view_left
@onready var eye_view_right: RayCast2D = $eye_view_right
@onready var shoot: RayCast2D = $shoot
@onready var exclaim: Node2D = $exclaim
@onready var frozen_ice: Node2D = $frozen_ice
@onready var fire: CPUParticles2D = $fire

@export var death_particles: PackedScene

var SPEED: float:
	get:
		return base_speed * speed_multiplier

func _ready() -> void:
	exclaim.visible = false
	$healthBar.value = health
	frozen_ice.visible = false
	fire.emitting = false

func _physics_process(delta: float) -> void:
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	shoot.target_position.x = direction * 200
	
	if not is_shooting and not frozen:
		if direction > 0:
			if (not rc_bottom_right.is_colliding() or eye_view_right.is_colliding()) and is_on_floor() and not stuck:
				direction = -1
				$Sprite2D.flip_h = true
		elif direction < 0:
			if (not rc_bottom_left.is_colliding() or eye_view_left.is_colliding()) and is_on_floor() and not stuck:
				direction = 1
				$Sprite2D.flip_h = false

		if ((eye_view_left.is_colliding() and eye_view_right.is_colliding()) 
		or (not rc_bottom_left.is_colliding() and not rc_bottom_right.is_colliding())):
			stuck = true
		else:
			stuck = false

		if stuck:
			velocity.x = 0
		else:
			velocity.x = SPEED * direction
	
	if shoot.is_colliding() and not frozen:
		var col = shoot.get_collider()
		if col and col.is_in_group("player"):
			base_speed = RUN_SPEED
			exclaim.visible = true

			if can_shoot:
				shoot_bullets(direction)
				stuck = true
				
	else:
		exclaim.visible = false
		base_speed = MIN_SPEED
		if not is_shooting:
			velocity.x = SPEED * direction
	
	if health <= 0:
		kill()
	
	if vacuum_force!= Vector2.ZERO:
		velocity+=vacuum_force
		vacuum_force = Vector2.ZERO
	if vacuum_force.length() > 0.1:
		print("Vacuum force:", vacuum_force)

	move_and_slide()

func shoot_bullets(dir: int) -> void:
	can_shoot = false
	is_shooting = true
	var bullet = preload("res://scenes/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = $Sprite2D/bullet_pos.global_position
	bullet.shoot_bullets(dir)
	bullet.set_dir(direction)
	$shoot_sound.play()
	bullet.get_child(1).emitting = true
	await get_tree().create_timer(1.5).timeout
	is_shooting = false
	await get_tree().create_timer(3).timeout
	can_shoot = true


func _on_player_catch_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.decrease_healh(10)
		body.apply_knockback(self, 20, 2)

func _on_head_body_entered(body: Node2D) -> void:
	if body.is_in_group("box"):
		body.get_node("crush").play()
		kill()

func decrease_health(damage: float) -> void:
	health -= damage
	$healthBar.value = health

func kill() -> void:
	$AudioStreamPlayer2D.play()
	if death_particles:
		var particle = death_particles.instantiate()
		particle.position = global_position
		particle.rotation = global_rotation
		particle.emitting = true
		get_tree().current_scene.add_child(particle)
	queue_free()

func freeze(duration: float = 4.0) -> void:
	decrease_health(10)
	if frozen: return
	frozen = true
	on_fire = false
	frozen_ice.visible = true
	fire.emitting = false
	velocity = Vector2.ZERO
	await get_tree().create_timer(duration).timeout
	frozen = false
	frozen_ice.visible = false

func burn(duration: float = 4.0) -> void:
	if on_fire: return
	on_fire = true
	frozen = false
	frozen_ice.visible = false
	fire.emitting = true

	speed_multiplier = 2.0

	for i in range(duration):
		if not on_fire: break
		decrease_health(2)
		await get_tree().create_timer(1.0).timeout

	speed_multiplier = 1.0
	fire.emitting = false
	on_fire = false

func lightning_strike(duration: float = 3.0) -> void:
	if lightning: return
	lightning = true
	decrease_health(5)
	speed_multiplier = 0.5
	await get_tree().create_timer(duration).timeout
	speed_multiplier = 1.0
	lightning = false

func apply_vacuum_pull(target_pos: Vector2, strength: float, delta: float) -> void:
	var dir = (target_pos - global_position).normalized()
	var dist = target_pos.distance_to(global_position)

	var force = strength / max(dist, 50.0)
	vacuum_force += dir * force * delta


func _on_other_enemy_body_entered(body: Node2D) -> void:
	if body and body.is_in_group("enemy") and on_fire:
		body.burn()
