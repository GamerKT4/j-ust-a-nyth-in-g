extends Control

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	get_parent().queue_free()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
