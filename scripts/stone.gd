extends RigidBody2D

var is_holding_mouse = false
@export var increase_per_hold = 0.1
@export var decrease_per_release = 0.5
@onready var pg_bar: ProgressBar = $Sprite2D/ProgressBar

func _process(delta: float) -> void:
	if Input.is_action_pressed("drag"):
		is_holding_mouse = true
	else:
		is_holding_mouse = false
	if is_holding_mouse:
		pg_bar.value+=increase_per_hold
	else:
		pg_bar.value-=decrease_per_release

func _physics_process(delta: float) -> void:
	if not is_holding_mouse:
		look_at(get_global_mouse_position())
	
