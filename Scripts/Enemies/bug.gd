extends CharacterBody2D

func _physics_process(_delta: float) -> void:
	var screen_center = get_viewport().size / 2.0
	
	var direction = (screen_center - global_position).normalized()
	
	rotation = direction.angle()
	
	velocity = direction * Variables.bug_speed
	move_and_slide()
