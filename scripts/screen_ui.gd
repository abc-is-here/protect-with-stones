extends Control

var menu_in = false
var control_in = false
var setting_in = false

@onready var health: TextureProgressBar = $Progress/Health
@onready var stamina: TextureProgressBar = $Progress/Stamina

func _ready() -> void:
	$controls_anim.play("reset")
	$Settings_anim.play("reset")
	
	health.step = 0.01
	stamina.step = 0.01

	health.min_value = 0
	health.max_value = 100
	stamina.min_value = 0
	stamina.max_value = Global.max_stamina

	health.value = (Global.player_health / Global.max_player_health) * 100.0
	stamina.value = Global.stamina
	
	$settings/resolutions.select(0)

func _process(_delta: float) -> void:
	health.value = Global.player_health
	$Progress/Stamina.value = Global.stamina

	if Global.stamina <= 0:
		$Progress/CPUParticles2D.emitting = false
	else:
		$Progress/CPUParticles2D.emitting = true
	
	if Global.stamina >=0 and Global.stamina <3:
		$Progress/CPUParticles2D.color = Color(0.0, 0.0, 0.0)
	if Global.stamina >=3 and Global.stamina <6:
		$Progress/CPUParticles2D.color = Color(0.793, 0.464, 0.0, 0.011)
	if Global.stamina >=6:
		$Progress/CPUParticles2D.color = Color(0.004, 0.533, 0.235)

	if Input.is_action_just_pressed("menu"):
		if not menu_in:
			menu_in = true
			$menu_anim.play("buttons_slide_in")
			$text_anim.play("text_in")
			stamina.modulate = Color(1, 1, 1, 0.51)
			get_tree().paused = true
		else:
			if control_in:
				control_in = false
				$controls_anim.play("controls_slide_up")
				await $controls_anim.animation_finished
				$controls_anim.play("reset")
				

			if setting_in:
				setting_in = false
				$Settings_anim.play("setting_side")
				await $Settings_anim.animation_finished
				$Settings_anim.play("reset")

			menu_in = false
			$menu_anim.play("buttons_slide_out")
			$text_anim.play("text_out")
			stamina.modulate = Color(1, 1, 1, 1)
			await $menu_anim.animation_finished
			get_tree().paused = false

func _on_controls_button_pressed() -> void:
	if not control_in:
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
