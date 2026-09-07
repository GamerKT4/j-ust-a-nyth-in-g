extends Node2D

const PAUSE_MENU_SCENE = preload("res://Scenes/UI/PauseMenu.tscn")
const GAME_OVER_SCENE = preload("res://Scenes/UI/GameOverMenu.tscn")


func _ready() -> void:
	# Keep this manager node processing even when the rest of the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not has_node("PauseMenu") and not has_node("GameOverMenu"):
		pause_game()


func pause_game() -> void:
	get_tree().paused = true

	var menu = PAUSE_MENU_SCENE.instantiate()
	menu.name = "PauseMenu"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	if menu.has_signal("resume_requested"):
		menu.resume_requested.connect(resume_game)
	if menu.has_signal("quit_requested"):
		menu.quit_requested.connect(cleanup_and_quit)
		
	add_child(menu)


func resume_game() -> void:
	get_tree().paused = false
	if has_node("PauseMenu"):
		$PauseMenu.queue_free()


func cleanup_and_quit() -> void:
	get_tree().paused = false
	if has_node("PauseMenu"):
		$PauseMenu.queue_free()
	get_tree().quit()


# This function runs when game over triggers
func _on_house_game_over_triggered() -> void:
	game_over()


func game_over() -> void:
	get_tree().paused = true

	var menu = GAME_OVER_SCENE.instantiate()
	menu.name = "GameOverMenu"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(menu)
