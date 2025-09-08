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

@export var decrease_stamina = 3
#damage
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

func _ready() -> void:
	hand_above_pos = hand_above.position
	$HealthBar.visible = false
	$damage.visible = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("run") and Global.stamina>0 and velocity.x != 0:
		speed = 400
		Global.stamina-=decrease_stamina*delta
		is_running = true
		stamina_timer.start()
	else:
		speed = 200
		is_running = false
		if Global.stamina < 10 and not stamina_timer.is_stopped():
			pass
		elif Global.stamina < 10:
			Global.stamina += decrease_stamina*delta
			
	if Input.is_action_just_pressed("drag"):
		charging = true
		cur_pull = 0
	
	if Input.is_action_pressed("drag") and charging:
		
		cur_pull = min(cur_pull + charge_speed*delta, max_pull)
		hand_above.position = hand_above_pos+Vector2(-cur_pull, 0).rotated(slingshot.rotation)
		Engine.time_scale = 0.2
		
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
		
	slingshot.look_at(get_global_mouse_position())
	slingshot.rotation = clamp(slingshot.rotation, deg_to_rad(-60), deg_to_rad(60))
	
	standing_on_box = false
	if rc_bottom.is_colliding():
		var obj = rc_bottom.get_collider()
		if obj.is_in_group("box"):
			standing_on_box = true
			
	$HealthBar.value = Global.player_health

func _physics_process(delta: float) -> void:
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
	var stone = preload("res://scenes/stone_new.tscn").instantiate()
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
	camera.screen_shake(0.7*decreased_health, 0.5)
	Global.player_health -= decreased_health
	$HealthBar.visible = true
	$damage.visible = true
	await get_tree().create_timer(0.1).timeout
	$damage.visible = false
	await get_tree().create_timer(2).timeout
	$HealthBar.visible = false

func apply_knockback(source: Node2D, force: float, duration: float):
	var dir = (global_position - source.global_position).normalized()
	knockback= Vector2(dir.x, 0).normalized()*force
	knockback.y = -35
	knockback_timer = duration
	knockback_particles.emitting = true
