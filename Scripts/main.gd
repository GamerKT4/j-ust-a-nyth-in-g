extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(e):
	if e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE:
		add_child(load("res://Scenes/PauseMenu.tscn").instantiate())
