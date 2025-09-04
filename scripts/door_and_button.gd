extends Node2D

var bodies_on_button := 0

#func _ready() -> void:
	#$door/CollisionShape2D.disabled = false

func _on_button_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("box"):
		bodies_on_button += 1
		$door/CollisionShape2D.disabled = true

func _on_button_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("box"):
		bodies_on_button = max(0, bodies_on_button - 1)
		if bodies_on_button == 0:
			$door/CollisionShape2D.disabled = false
