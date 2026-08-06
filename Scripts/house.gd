extends Node2D

signal game_over_triggered

var health = 500
var is_game_over = false

func _on_area_2d_body_entered(body) -> void:
	if is_game_over:
		return

	if body.is_in_group("Enemies"):
		body.queue_free()

		health = health - 10
		$ProgressBar.value = health

		if health <= 0:
			is_game_over = true
			game_over_triggered.emit()
