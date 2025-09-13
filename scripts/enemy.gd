extends CharacterBody2D

var SPEED = 100.0
const min_speed = 100
const run_speed = 150
const GRAVITY = 800.0

@onready var rc_bottom_left: RayCast2D = $rc_bottom_left
@onready var rc_bottom_right: RayCast2D = $rc_bottom_right
@onready var eye_view_left: RayCast2D = $eye_view_left
@onready var eye_view_right: RayCast2D = $eye_view_right
@onready var shoot: RayCast2D = $shoot

@export var death_particles: PackedScene
#shoot_bullets
var direction := 1
var stuck := false

var player_visible = false

var can_shoot = true
var is_shooting = false

func  _ready() -> void:
	$exclaim.visible = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	shoot.target_position.x = direction*200
	
	if not is_shooting:
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
	
	if shoot.is_colliding():
		var col = shoot.get_collider()
		if col:
			if col.is_in_group("player"):
				SPEED = run_speed
				$exclaim.visible = true

			if col.is_in_group("player") and can_shoot:
				shoot_bullets(direction)
				velocity.x = 0
	else:
		$exclaim.visible = false
		SPEED = min_speed
		if not is_shooting:
			velocity.x = SPEED*direction
		

	move_and_slide()

func shoot_bullets(dir):
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

func kill():
	$AudioStreamPlayer2D.play()
	if death_particles:
		var particle = death_particles.instantiate()
		particle.position = global_position
		particle.rotation = global_rotation
		particle.emitting = true
		
		get_tree().current_scene.add_child(particle)
	queue_free()

func _on_head_body_entered(body: Node2D) -> void:
	if body.is_in_group("box"):
		body.get_node("crush").play()
		kill()
