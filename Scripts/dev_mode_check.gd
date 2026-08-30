extends Node

var times_dev_key_pressed: int = 0
var is_in_dev_mode: bool = false

func _process(delta):
	if Input.is_action_just_pressed("dev_key"):
		times_dev_key_pressed += 1
		
		if times_dev_key_pressed == 1:
			
			
			if is_in_dev_mode:
				print("You're ALREADY a dev! WHAT ELSE DO YOU WANT?")
			
			if not is_in_dev_mode:
				print("You're a dev!")
				is_in_dev_mode = true
				times_dev_key_pressed = 0
				
				var slider = get_tree().get_first_node_in_group("dev_ui")
				if slider:
					slider.visible = true
