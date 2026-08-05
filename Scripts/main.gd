extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not has_node("PauseMenu"):
		pause_game()

func pause_game() -> void:
	get_tree().paused = true
	toggle_children_pause(Node.PROCESS_MODE_DISABLED)

	var menu = load("res://Scenes/PauseMenu.tscn").instantiate()
	menu.name = "PauseMenu"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	menu.resume_requested.connect(resume_game)
	add_child(menu)

func resume_game() -> void:
	get_tree().paused = false
	if has_node("PauseMenu"):
		get_node("PauseMenu").queue_free()
	toggle_children_pause(Node.PROCESS_MODE_INHERIT)

# Freezes or unfreezes every child script and spawner attached to Main
func toggle_children_pause(mode: ProcessMode) -> void:
	for child in get_children():
		if child.name != "PauseMenu":
			child.process_mode = mode
