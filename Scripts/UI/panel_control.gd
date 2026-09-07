extends CanvasLayer

signal resume_requested

func _on_resume_button_pressed() -> void:
	resume_requested.emit()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
