extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var max_pull = 15.0
@export var charge_speed = 10.0
@export var shoot_power = 100.0

@onready var slingshot: Sprite2D = $Slingshot
@onready var hand_above: Sprite2D = $Slingshot/HandAbove
@onready var stone_pos: Marker2D = $Slingshot/stone_pos

var hand_above_pos: Vector2
var cur_pull = 0.0
var charging = false

func _ready() -> void:
	hand_above_pos = hand_above.position

func _process(delta: float) -> void:
	if Input.is_action_pressed("drag"):
		charging = true
		cur_pull = min(cur_pull + charge_speed*delta, max_pull)
		hand_above.position = hand_above_pos+Vector2(-cur_pull, 0)
		
	if Input.is_action_just_released("drag") and charging:
		shoot_stone(cur_pull)
		charging = false
		cur_pull = 0
		hand_above.position = hand_above_pos
	
	slingshot.look_at(get_global_mouse_position())
	slingshot.rotation = clamp(slingshot.rotation, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func shoot_stone(strength: float) -> void:
	var stone = preload("res://scenes/stone_new.tscn").instantiate()
	get_parent().add_child(stone)
	stone.global_position = stone_pos.global_position
	
	var dir = slingshot.transform.x.normalized()
	stone.apply_impulse(dir * strength * shoot_power)
