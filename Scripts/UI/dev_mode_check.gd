extends Node

var is_in_dev_mode: bool = false

func _ready() -> void:
	# Ensure the key works even when paused or reloading
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("dev_key"):
		_toggle_dev_mode()

func _toggle_dev_mode() -> void:
	is_in_dev_mode = !is_in_dev_mode
	 
	var dev_ui = get_tree().get_nodes_in_group("dev_ui")
	
	if is_in_dev_mode:
		print("Dev mode: ON")
		for node in dev_ui:
			node.visible = true
	else:
		print("Dev mode: OFF")
		for node in dev_ui:
			node.visible = false

# Call this on restart if you want dev mode reset
func reset_dev_mode() -> void:
	is_in_dev_mode = false
