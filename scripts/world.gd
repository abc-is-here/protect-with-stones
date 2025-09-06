extends Node2D

func reset() -> void:
	Global.player_health = Global.max_player_health
	Global.stamina = Global.max_stamina

func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("respawn"):
		get_tree().change_scene_to_file("res://scenes/world.tscn")
		reset()
		

	if Global.player_health <= 0:
		get_tree().change_scene_to_file("res://scenes/world.tscn")
		reset()


func _on_fall_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/world.tscn")
		reset()
		
