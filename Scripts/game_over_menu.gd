extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Control/VBoxContainer/RestartButton.pressed.connect(_on_restart_button_pressed)
	$Control/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	pass # Replace with function body.
