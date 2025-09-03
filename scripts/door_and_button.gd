extends Node2D

@export var door_offset: float = 620

var door_closed_pos: Vector2
var door_open_pos: Vector2
var bodies_on_button := 0

func _ready() -> void:
	door_closed_pos = $door.position
	door_open_pos = door_closed_pos + Vector2(0, door_offset)

func _on_button_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("box"):
		bodies_on_button += 1
		$door.position = door_open_pos

func _on_button_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("box"):
		bodies_on_button = max(0, bodies_on_button - 1)
		if bodies_on_button == 0:
			$door.position = door_closed_pos
