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
	
	var dev_ui = get_tree().get_first_node_in_group("dev_ui")
	if dev_ui:
		dev_ui.visible = is_in_dev_mode
		print("Dev mode: ", "ON" if is_in_dev_mode else "OFF")
	else:
		print("Dev UI node not found in group 'dev_ui'!")

# Call this on restart if you want dev mode reset
func reset_dev_mode() -> void:
	is_in_dev_mode = false
