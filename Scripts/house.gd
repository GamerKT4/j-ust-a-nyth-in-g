extends Node2D

signal game_over_triggered

var house_health = Variables.house_health
var is_game_over = false

func _on_area_2d_body_entered(body) -> void:
	if is_game_over:
		return

	if body.is_in_group("Enemies"):
		body.queue_free()

		house_health = house_health - Variables.bug_damage
		$ProgressBar.value = house_health

		if house_health <= 0:
			is_game_over = true
			game_over_triggered.emit()
