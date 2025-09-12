extends Control

var menu_in = false
var control_in = false
var setting_in = false

func _ready() -> void:
	$controls_anim.play("reset")
	$Settings_anim.play("reset")

func _process(_delta: float) -> void:
	$ProgressBar.value = Global.stamina

	if Input.is_action_just_pressed("menu"):
		if not menu_in:
			# Open main menu
			menu_in = true
			$menu_anim.play("buttons_slide_in")
			$text_anim.play("text_in")
			$ProgressBar.modulate = Color(1, 1, 1, 0.51)
			get_tree().paused = true
		else:
			# Close submenus first
			if control_in:
				control_in = false
				$controls_anim.play("controls_slide_up")
				await $controls_anim.animation_finished
				$controls_anim.play("reset")
				return

			if setting_in:
				setting_in = false
				$Settings_anim.play("setting_side")
				await $Settings_anim.animation_finished
				$Settings_anim.play("reset")
				return

			# Close main menu last
			menu_in = false
			$menu_anim.play("buttons_slide_out")
			$text_anim.play("text_out")
			$ProgressBar.modulate = Color(1, 1, 1, 1)
			await $menu_anim.animation_finished
			get_tree().paused = false

func _on_controls_button_pressed() -> void:
	if not control_in:
		# Close settings first if open
		if setting_in:
			setting_in = false
			$Settings_anim.play("setting_side")
			await $Settings_anim.animation_finished
			$Settings_anim.play("reset")

		$controls_anim.play("controls_slide_in")
		control_in = true
	else:
		control_in = false
		$controls_anim.play("controls_slide_up")
		await $controls_anim.animation_finished
		$controls_anim.play("reset")

func _on_settings_button_pressed() -> void:
	if not setting_in:
		# Close controls first if open
		if control_in:
			control_in = false
			$controls_anim.play("controls_slide_up")
			await $controls_anim.animation_finished
			$controls_anim.play("reset")

		$Settings_anim.play("setting_up")
		setting_in = true
	else:
		setting_in = false
		$Settings_anim.play("setting_side")
		await $Settings_anim.animation_finished
		$Settings_anim.play("reset")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value/5)

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)

func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_size(Vector2i(2304, 1296))
		1: DisplayServer.window_set_size(Vector2i(1920, 1080))
		2: DisplayServer.window_set_size(Vector2i(1600, 900))
		3: DisplayServer.window_set_size(Vector2i(1280, 720))
