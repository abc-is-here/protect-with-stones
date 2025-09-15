extends Node2D

var player_pos : Vector2

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

func reset():
	call_deferred("handle_reset")

func handle_reset() -> void:
	$player.position = player_pos
	Global.player_health = Global.max_player_health
	Global.stamina = Global.max_stamina

func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("respawn"):
		Global.trigger_death("reset")
		reset()
		

	if Global.player_health <= 0:
		$player.kill()
		await get_tree().create_timer(1).timeout
		$player.position = player_pos
		Global.trigger_death("died")
		Global.player_health = Global.max_player_health
		Global.stamina = Global.max_stamina
		
	
	if Input.is_action_just_pressed("enter"):
		$stop/CollisionShape2D.disabled = true
		$start/Label.text = "GO!! Go!! Go!! Go!! Go!!"
		$stop/ColorRect.modulate = Color(1, 1, 1, 0.051)

func _on_fall_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.trigger_death("fell")
		reset()
		
