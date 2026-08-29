extends Node

var times_dev_key_pressed: int = 0
var is_in_dev_mode: bool = false

func _process(float):
	if Input.is_action_just_pressed("dev_key"):
		times_dev_key_pressed += 1
		
		if times_dev_key_pressed == 7:
			
			
			if is_in_dev_mode:
				print("You're ALREADY a dev! WHAT ELSE DO YOU WANT?")
			
			if not is_in_dev_mode:
				print("You're a dev!")
				is_in_dev_mode = true
				times_dev_key_pressed = 0
