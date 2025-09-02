extends CharacterBody2D

@export var max_pull: float = 15.0
@export var charge_speed: float = 10.0
@export var shoot_power: float = 100.0

@export var speed: float = 200
@export var acc:int = 5
@export var dcc: int = 3
@export var jump_speed: int = -speed*3
@export var gravity: float = speed*5
@export var fall_factor: float = 3.0

@export var zoom_min: Vector2 = Vector2(0.5000001, 0.5000001)
@export var zoom_max: Vector2 = Vector2(2.5000001, 2.5000001)
@export var zoom_speed: Vector2 = Vector2(0.1000001, 0.1000001)

@onready var slingshot: Sprite2D = $AnimatedSprite2D/Slingshot
@onready var hand_above: Sprite2D = $AnimatedSprite2D/Slingshot/HandAbove
@onready var stone_pos: Marker2D = $AnimatedSprite2D/Slingshot/stone_pos
@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var hand_above_pos_mark: Marker2D = $AnimatedSprite2D/Slingshot/hand_above_pos
@onready var camera: Camera2D = $Camera2D

var hand_above_pos: Vector2
var cur_pull: float = 0.0
var charging: bool = false

enum State{IDLE, WALK, JUMP, DOWN}
var cur_state: State = State.IDLE

func _ready() -> void:
	hand_above_pos = hand_above.position

func _process(delta: float) -> void:
	if Input.is_action_pressed("drag"):
		charging = true
		cur_pull = min(cur_pull + charge_speed*delta, max_pull)
		hand_above.position = hand_above_pos+Vector2(-cur_pull, 0).rotated(slingshot.rotation)
		
	if Input.is_action_just_released("drag") and charging:
		shoot_stone(cur_pull)
		charging = false
		cur_pull = 0
		hand_above.position = hand_above.position.lerp(Vector2(-3.0, -1.0), 1)
		
	slingshot.look_at(get_global_mouse_position())
	slingshot.rotation = clamp(slingshot.rotation, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	handle_inp()
	update_move(delta)
	update_states()
	update_anim()
	move_and_slide()

func handle_inp() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_buffer_timer.start()

	var direction = Input.get_axis("left", "right")
	
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, acc)
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
		animations.scale.x=sign(velocity.x) *abs(animations.scale.x)
	
	match cur_state:
		State.IDLE: animations.play("idle")
		State.WALK: animations.play("walk")
		State.JUMP: animations.play("jump_up")
		State.DOWN: animations.play("fall")

func update_move(delta: float) -> void:
	if (is_on_floor() or coyote_timer.time_left>0) and jump_buffer_timer.time_left >0:
		velocity.y = jump_speed
		cur_state = State.JUMP
		jump_buffer_timer.stop()
		coyote_timer.stop( )
		
		
	if cur_state == State.JUMP:
		velocity.y+=gravity*delta
	else:
		velocity.y+=gravity*delta*fall_factor

func update_states() -> void:
	match cur_state:
		State.IDLE when velocity.x != 0:
			cur_state = State.WALK
		State.WALK:
			if velocity.x ==0:
				cur_state = State.IDLE
			if not is_on_floor() and velocity.y>0:
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
