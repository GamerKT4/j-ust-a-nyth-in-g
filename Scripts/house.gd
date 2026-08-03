extends Node2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("Enemies"):
		print("You lost!")
		body.queue_free()
