extends CharacterBody2D

const SPEED = 100.0
const GRAVITY = 800.0

@onready var rc_bottom_left: RayCast2D = $rc_bottom_left
@onready var rc_bottom_right: RayCast2D = $rc_bottom_right
@onready var eye_view_left: RayCast2D = $eye_view_left
@onready var eye_view_right: RayCast2D = $eye_view_right
@onready var shoot: RayCast2D = $shoot

var direction := 1
var stuck := false

var player_visible = false

var can_shoot = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	shoot.target_position.x = direction*200
	
	if not player_visible:
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
		$exclaim.visible = true
		if col.is_in_group("player") and can_shoot:
			shoot_bullets(direction)
	else:
		$exclaim.visible = false
		

	move_and_slide()

func shoot_bullets(dir):
	can_shoot = false
	var bullet = preload("res://scenes/bullet.tscn").instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = $Sprite2D/bullet_pos.global_position
	bullet.shoot_bullets(dir)
	bullet.set_dir(direction)
	await get_tree().create_timer(3).timeout
	can_shoot = true
