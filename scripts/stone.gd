extends RigidBody2D

var is_holding_mouse = false
var is_shooting = false
@export var increase_per_hold = 0.1
@export var decrease_per_release = 0.5
@export var max_power = 100
@export var mul = 20
var shot_once = false
@onready var pg_bar: ProgressBar = $Sprite2D/ProgressBar

func _process(delta: float) -> void:
	if Input.is_action_pressed("drag") and not shot_once:
		is_holding_mouse = true
		pg_bar.value = clamp(pg_bar.value + increase_per_hold, 0, max_power)
	
	if Input.is_action_just_released("drag") and is_holding_mouse and not shot_once:
		shoot_stone()
		shot_once = true
		is_holding_mouse = false
	
	if not is_holding_mouse and pg_bar.value > 0:
		pg_bar.value = max(pg_bar.value - decrease_per_release, 0)

func _physics_process(delta: float) -> void:
	if is_holding_mouse:
		look_at(get_global_mouse_position())
	
func shoot_stone() -> void:
	var direction = (get_global_mouse_position() - global_position).normalized()
	var force = direction*pg_bar.value *mul
	apply_impulse(force)
	pg_bar.value = 0
