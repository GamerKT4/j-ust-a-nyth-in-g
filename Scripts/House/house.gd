extends Node2D

signal game_over_triggered

var house_health: float = 0.0
var is_game_over: bool = false

func _ready() -> void:
	house_health = Variables.house_health
	$ProgressBar.max_value = Variables.max_house_health
	$ProgressBar.value = house_health

	# Listen for house fortification upgrades from the shop
	if Variables.has_signal("house_health_updated"):
		Variables.house_health_updated.connect(_on_house_health_updated)

func _on_house_health_updated(current_hp: float, max_hp: float) -> void:
	house_health = current_hp
	$ProgressBar.max_value = max_hp
	$ProgressBar.value = house_health

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_game_over:
		return

	if body.is_in_group("Enemies"):
		body.call_deferred("queue_free")

		house_health -= Variables.bug_damage
		Variables.house_health = house_health
		$ProgressBar.value = house_health

		if house_health <= 0:
			is_game_over = true
			$Area2D.set_deferred("monitoring", false)
			$Area2D.set_deferred("monitorable", false)
			game_over_triggered.emit()
