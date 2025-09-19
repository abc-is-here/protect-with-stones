extends Area2D

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	rotation+=5*delta
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.choose_random_power()
		$Sprite2D.visible = false
		$CPUParticles2D2.emitting = true
		$CPUParticles2D.emitting = false
		set_deferred("monitoring", false)
