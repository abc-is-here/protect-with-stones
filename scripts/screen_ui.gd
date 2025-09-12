extends Control

var menu_in = false

func _process(_delta: float) -> void:
	$ProgressBar.value = Global.stamina
	
	if Input.is_action_just_pressed("menu"):
		if menu_in:
			menu_in = false
			$menu_anim.play("slide_out_menu")
			$text_anim.play("text_out")
			$ProgressBar.modulate = Color(1.0, 1.0, 1.0)
			get_tree().paused = false
		else:
			menu_in = true
			$menu_anim.play("slide_in_menu")
			$text_anim.play("text_in")
			$ProgressBar.modulate = Color(1.0, 1.0, 1.0, 0.51)
			get_tree().paused = true

func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_controls_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
