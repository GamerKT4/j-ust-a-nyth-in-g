extends Node

var basic_bug = preload("res://Scenes/basic_bug.tscn")

var spawn_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# 1. Timer using Variables.spawn_delay
	spawn_timer += delta
	if spawn_timer >= Variables.spawn_delay:
		spawn_timer = 0.0
		spawn_bug_offscreen()

func spawn_bug_offscreen() -> void:
	var screen_size = get_viewport().size
	var spawn_pos = Vector2.ZERO
	
	# Pick a side: 1 = Top, 2 = Bottom, 3 = Left, 4 = Right
	var side = randi_range(1, 4)
	var margin = Variables.spawn_margin
	
	if side == 1: # TOP (Above screen)
		spawn_pos.x = randf_range(0, screen_size.x)
		spawn_pos.y = -margin
	elif side == 2: # BOTTOM (Below screen)
		spawn_pos.x = randf_range(0, screen_size.x)
		spawn_pos.y = screen_size.y + margin
	elif side == 3: # LEFT (Left of screen)
		spawn_pos.x = -margin
		spawn_pos.y = randf_range(0, screen_size.y)
	elif side == 4: # RIGHT (Right of screen)
		spawn_pos.x = screen_size.x + margin
		spawn_pos.y = randf_range(0, screen_size.y)
		
	# Spawn the bug at the off-screen position
	var bug = basic_bug.instantiate()
	add_child(bug)
	bug.global_position = spawn_pos
