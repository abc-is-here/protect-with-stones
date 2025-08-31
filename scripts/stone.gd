extends RigidBody2D

var is_holding_mouse:bool = false
var is_shooting:bool = false
@export var increase_per_hold:float = 0.8
@export var max_power:float = 100.0
@export var mul:float = 20.0
var shot_once:bool = false
var aim_pos: Vector2
@onready var pg_bar: ProgressBar = $Sprite2D/ProgressBar

func _process(delta: float) -> void:
	if Input.is_action_pressed("drag") and not shot_once:
		if not is_holding_mouse:
			aim_pos = get_global_mouse_position()
		is_holding_mouse = true
		pg_bar.value = clamp(pg_bar.value + increase_per_hold, 0, max_power)
	
	if Input.is_action_just_released("drag") and is_holding_mouse and not shot_once:
		shoot_stone()
		shot_once = true
		is_holding_mouse = false
		
func _physics_process(delta: float) -> void:
	if not is_holding_mouse and not shot_once:
		look_at(get_global_mouse_position())
	
func shoot_stone() -> void:
	var direction = (aim_pos - global_position).normalized()
	var force = direction*pg_bar.value *mul
	apply_impulse(force)
	pg_bar.value = 0
