extends Node2D

var player_pos : Vector2
@onready var fade: ColorRect = $CanvasLayer/FadeRect


func _ready() -> void:
	player_pos = $player.position
	$player/death_counter.text = Global.death_text
	var stylebox := $player/death_counter.get_theme_stylebox("normal") as StyleBoxFlat
	if stylebox and $player/death_counter.text != "":
		stylebox.bg_color = Color(0, 0, 0, 0.9)
	await get_tree().create_timer(2).timeout
	$player/death_counter.text = ""
	if stylebox:
		stylebox.bg_color = Color(0.6, 0.6, 0.6, 0.0)
	fade.modulate.a = 1
	fade.show()
	fade.create_tween().tween_property(fade, "modulate:a", 0.0, 0.5)

func reset():
	call_deferred("handle_reset")

func handle_reset() -> void:
	$player.kill()
	await get_tree().create_timer(1).timeout
	$player.position = player_pos
	Global.player_health = Global.max_player_health
	Global.stamina = Global.max_stamina
	await get_tree().create_timer(1).timeout
	fade_in()
	
func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("respawn"):
		reset()
		

	if Global.player_health <= 0:
		handle_reset()
		
	
	if Input.is_action_just_pressed("enter"):
		$stop/CollisionShape2D.disabled = true
		$start/Label.text = "GO!! Go!! Go!! Go!! Go!!"
		$stop/ColorRect.modulate = Color(1, 1, 1, 0.051)

func _on_fall_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		reset()
		

func fade_in():
	fade.modulate.a = 0
	fade.show()
	var tween = fade.create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.2)
	tween.finished.connect(func ():
		get_tree().reload_current_scene()
	)
