extends Node2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not has_node("PauseMenu") and not has_node("GameOverMenu"):
		pause_game()

func pause_game() -> void:
	get_tree().paused = true
	call_deferred("toggle_children_pause", Node.PROCESS_MODE_DISABLED)

	var menu = load("res://Scenes/PauseMenu.tscn").instantiate()
	menu.name = "PauseMenu"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	menu.resume_requested.connect(resume_game)
	add_child(menu)

func resume_game() -> void:
	get_tree().paused = false
	if has_node("PauseMenu"):
		$PauseMenu.queue_free()
	call_deferred("toggle_children_pause", Node.PROCESS_MODE_INHERIT)

# This function runs when game over triggers
func _on_house_game_over_triggered() -> void:
	game_over()

func game_over() -> void:
	get_tree().paused = true
	call_deferred("toggle_children_pause", Node.PROCESS_MODE_DISABLED)

	var menu = load("res://Scenes/GameOverMenu.tscn").instantiate()
	menu.name = "GameOverMenu"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(menu)

func toggle_children_pause(mode: ProcessMode) -> void:
	for child in get_children():
		if child.name != "PauseMenu" and child.name != "GameOverMenu":
			child.process_mode = mode
