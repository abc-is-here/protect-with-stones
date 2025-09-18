extends CharacterBody2D

@export var max_pull: float = 15.0
@export var charge_speed: float = 15.0
@export var shoot_power: float = 80.0

@export var speed: float = 200
@export var acc:int = 7
@export var dcc: int = 6
@export var jump_speed: int = -800
@export var gravity: float = 1400
@export var fall_factor: float = 1.3

@export var zoom_min: Vector2 = Vector2(0.5000001, 0.5000001)
@export var zoom_max: Vector2 = Vector2(2.5000001, 2.5000001)
@export var zoom_speed: Vector2 = Vector2(0.1000001, 0.1000001)

@export var decrease_stamina = 2

@onready var shield_particles: CPUParticles2D = $ShieldParticles
@onready var slingshot: Sprite2D = $AnimatedSprite2D/Slingshot
@onready var hand_above: Sprite2D = $AnimatedSprite2D/Slingshot/HandAbove
@onready var stone_pos: Marker2D = $AnimatedSprite2D/Slingshot/stone_pos
@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var hand_above_pos_mark: Marker2D = $AnimatedSprite2D/Slingshot/hand_above_pos
@onready var camera: Camera2D = $main_camera
@onready var rc_bottom: RayCast2D = $rc_bottom
@onready var stamina_timer: Timer = $StaminaTimer
@onready var jump_particles: CPUParticles2D = $JumpParticles
@onready var projectile_path: Node2D = $ProjectilePath
@onready var knockback_particles: CPUParticles2D = $knockbackParticles
@onready var shield_anim: AnimationPlayer = $shield_anim
@onready var shield_sound: AudioStreamPlayer2D = $shield_sound

var hand_above_pos: Vector2
var cur_pull: float = 0.0
var charging: bool = false

enum State{IDLE, WALK, JUMP, DOWN}
var cur_state: State = State.IDLE
var is_pushing = false

var is_running = false

var PUSH_FORCE = 140.0
const BOX_MAX_VELOCITY = 180
var standing_on_box = false

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var facing_dir = 1
var shield_active = false
var shield_broken = false
var can_rgen_staminea = false
var can_move = true

@export var stone_variants: Array[PackedScene] = [
	preload("res://scenes/stone_ice.tscn"),
	preload("res://scenes/stone_fire.tscn"),
	preload("res://scenes/stone_lightning.tscn")
]

var normal_stone: PackedScene = preload("res://scenes/stone_new.tscn")
var cur_stone: PackedScene = preload("res://scenes/stone_new.tscn")

func _ready() -> void:
	hand_above_pos = hand_above.position
	$damage.visible = false
	randomize()

func _process(delta: float) -> void:
	if Input.is_action_pressed("run") and Global.stamina>0 and velocity.x != 0:
		speed = 400
		Global.stamina-=decrease_stamina*delta
		is_running = true
		can_rgen_staminea = false
		stamina_timer.start()
	else:
		speed = 200
		is_running = false
	if Input.is_action_pressed("shield") and Global.stamina>0:
		Global.stamina-=decrease_stamina*delta*1.5
		can_rgen_staminea = false
		stamina_timer.start()
		
	if can_rgen_staminea:
		Global.stamina = min(Global.stamina + 0.5 * delta, Global.max_stamina)
		
	if Input.is_action_just_pressed("drag"):
		charging = true
		cur_pull = 0
	
	if Input.is_action_pressed("drag") and charging:
		
		cur_pull = min(cur_pull + charge_speed*delta, max_pull)
		hand_above.position = hand_above_pos+Vector2(-cur_pull, 0).rotated(slingshot.rotation)
		Engine.time_scale = 0.2
		Global.is_slowed = true
		
		var start_pos = stone_pos.global_position
		var dir = slingshot.global_transform.x.normalized()
		projectile_path.draw_path(start_pos, dir * shoot_power * cur_pull)
		projectile_path.visible = true
		
	if Input.is_action_just_released("drag") and charging:
		shoot_stone(cur_pull)
		charging = false
		cur_pull = 0
		hand_above.position = hand_above_pos
		Engine.time_scale = 1.0
		projectile_path.visible = false
		Global.is_slowed = false
		
	slingshot.look_at(get_global_mouse_position())
	slingshot.rotation = clamp(slingshot.rotation, deg_to_rad(-90), deg_to_rad(90))
	
	standing_on_box = false
	if rc_bottom.is_colliding():
		var obj = rc_bottom.get_collider()
		if obj and obj.is_in_group("box"):
			standing_on_box = true

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity.x = 0
		velocity.y += gravity * delta
		move_and_slide()
		return
	is_pushing = false
	handle_inp()
	if knockback_timer > 0.0:
		velocity+=knockback
		knockback = knockback.move_toward(Vector2.ZERO, 50 * delta)
		knockback_timer -= delta
	else:
		knockback = Vector2.ZERO
	update_move(delta)
	update_states()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_block = collision.get_collider()
		if collision_block is RigidBody2D and collision_block.is_in_group("box"):
			if abs(collision_block.get_linear_velocity().x) < BOX_MAX_VELOCITY:
				if standing_on_box and abs(collision.get_normal().y) > 0.9:
					continue
				collision_block.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)
	
	if Input.is_action_pressed("shield") and Global.stamina > 0 and not shield_broken:
		if not shield_active:
			shield_particles.emitting = true
			shield_anim.play("shield_start")
			shield_active = true
			shield_sound.play()
		
		
		if Global.stamina <= 0:
			shield_active = false
			shield_broken = true
			shield_anim.play("shield_end")
			shield_particles.emitting = false

	elif shield_active and (Input.is_action_just_released("shield")):
		shield_active = false
		shield_particles.emitting = false
		shield_anim.play("shield_end")
		shield_sound.stop()
		
	if shield_broken and Global.stamina >= 1:
		shield_broken = false
		
	if Global.stamina <= 0 and shield_active:
		shield_active = false
		shield_particles.emitting = false
		shield_anim.play("shield_end")
		shield_broken = true
		shield_sound.stop()
	
	if velocity.x != 0 and velocity.y != 0:
		$walk.emitting = true
	else:
		$walk.emitting = false
	
	update_anim()
	move_and_slide()

func handle_inp() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()

	var direction = Input.get_axis("left", "right")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, speed*direction, acc)
		facing_dir = sign(direction)
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, dcc)
	else:
		velocity.x = move_toward(velocity.x, speed*direction, acc)

func shoot_stone(strength: float) -> void:
	var stone = cur_stone.instantiate()
	get_parent().add_child(stone)
	stone.global_position = stone_pos.global_position
	
	var dir = slingshot.global_transform.x.normalized()
	stone.apply_impulse(dir * strength * shoot_power)

func update_anim() -> void:
	if velocity.x != 0:
		animations.scale.x=facing_dir *abs(animations.scale.x)
		
	match cur_state:
		State.IDLE: animations.play("idle")
		State.WALK: animations.play("walk")
		State.JUMP: animations.play("jump_up")
		State.DOWN: animations.play("fall")

func update_move(delta: float) -> void:
	if (is_on_floor() or coyote_timer.time_left > 0.0) and jump_buffer_timer.time_left > 0.0:
		velocity.y = jump_speed
		cur_state = State.JUMP
		jump_buffer_timer.stop()
		coyote_timer.stop()
		
		$Jump.play()
		jump_particles.emitting = true
		jump_particles.restart()

	if velocity.y < 0.0:
		var up_mult = 1.0 if Input.is_action_pressed("jump") else 2.8
		velocity.y += gravity * up_mult * delta
	else:
		velocity.y += gravity * fall_factor * delta
		if is_on_floor():
			$FallParticles.emitting = true

func update_states() -> void:
	match cur_state:
		State.IDLE when velocity.x != 0:
			cur_state = State.WALK
		State.WALK:
			if velocity.x ==0:
				cur_state = State.IDLE
			if not is_on_floor():
				cur_state = State.JUMP
				coyote_timer.start()
		
		State.JUMP when velocity.y>0:
			cur_state = State.DOWN
		
		State.DOWN when is_on_floor():
			if velocity.x == 0:
				cur_state = State.IDLE
			else:
				cur_state = State.WALK

func _input(event: InputEvent) -> void:
	var zoom_change := 0.0

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_change = -0.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_change = 0.1

	elif event is InputEventPanGesture:
		zoom_change = event.delta.y * 0.01

	if zoom_change != 0.0:
		var zoom = camera.zoom.x
		zoom = clampf(zoom + zoom_change, zoom_min.x, zoom_max.x)
		camera.zoom = Vector2(zoom, zoom)

func decrease_healh(decreased_health):
	if shield_active and Global.stamina > 0:
		return
	camera.screen_shake(0.9*decreased_health, 0.5)
	Global.player_health -= decreased_health
	$damage.visible = true
	await get_tree().create_timer(0.2).timeout
	$damage.visible = false

func apply_knockback(source: Node2D, force: float, duration: float):
	var dir = (global_position - source.global_position).normalized()
	knockback= Vector2(dir.x, 0).normalized()*force
	knockback_timer = duration
	knockback_particles.emitting = true

func _on_stamina_timer_timeout() -> void:
	can_rgen_staminea = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("water") and Global.player_health >= 81:
		$water.emitting = true
		$water.restart()
		camera.screen_shake(0.7*80, 0.5)
		

func kill():
	$AnimatedSprite2D.visible = false
	$perish.emitting = true
	$perish.restart()
	can_move = false
	
	await get_tree().create_timer(1).timeout
	$AnimatedSprite2D.visible = true
	can_move = true
	

func choose_random_power():
	var rand_index = randi() % stone_variants.size()
	cur_stone = stone_variants[rand_index]
	await get_tree().create_timer(60).timeout
	cur_stone = normal_stone

func choose_lightning() -> void:
	cur_stone = preload("res://scenes/stone_lightning.tscn")
	await get_tree().create_timer(60).timeout
	cur_stone = normal_stone
