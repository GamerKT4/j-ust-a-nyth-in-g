extends Node2D

@onready var cooldown: Timer = $Cooldown
var gun_is_cool: bool


func _ready() -> void:
	gun_is_cool = true

func _on_cooldown_timeout() -> void:
	if not gun_is_cool:
		gun_is_cool = true


func _on_body_entered_in_range(body: Node2D) -> void:
	if gun_is_cool:
		body.queue_free()
		print("Enemy killed!")
		gun_is_cool = false
		cooldown.start()
