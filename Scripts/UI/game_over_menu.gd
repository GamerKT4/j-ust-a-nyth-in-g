extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true  # Freezes the rest of the game
	
	var restart_btn = $Control/VBoxContainer/RestartButton
	if not restart_btn.pressed.is_connected(_on_restart_button_pressed):
		restart_btn.pressed.connect(_on_restart_button_pressed)
		
	var quit_btn = $Control/VBoxContainer/QuitButton
	if not quit_btn.pressed.is_connected(_on_quit_button_pressed):
		quit_btn.pressed.connect(_on_quit_button_pressed)


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	Variables.reset_game()
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
