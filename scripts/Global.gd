extends Node

var stamina: float = 10.0
var max_stamina: float = 10.0
var player_health: float = 100.0
var max_player_health: float = 100.0

var has_reset = false
var has_died = false
var fell = false
var death_text: String = ""

func show_death_message(message: String) -> void:
	death_text = message
	await get_tree().create_timer(1.0).timeout
	death_text = ""
	has_reset = false
	has_died = false
	fell = false

func trigger_death(reason: String) -> void:
	match reason:
		"died":
			has_died = true
			await show_death_message("You died… but hey, free teleport!")
		"reset":
			has_reset = true
			await show_death_message("Respawning… because game devs are merciful.")
		"fell":
			fell = true
			await show_death_message("That’s one way to test gravity.")
