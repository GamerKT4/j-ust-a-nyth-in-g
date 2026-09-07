extends Node

var basic_bug = preload("res://Scenes/Enemies/basic_bug.tscn")

@export var wave_ui: Control

# Wave State Trackers
var spawn_timer: float = 0.0
var wave_timer: float = 0.0
var bugs_spawned_this_wave: int = 0
var is_spawning_phase: bool = true

func _ready() -> void:
	if wave_ui:
		wave_ui.ready_button_pressed.connect(_on_ready_button_pressed)
		wave_ui.update_wave_text(Variables.current_wave)
		wave_ui.hide_timer()
		if wave_ui.has_method("hide_ready_button"):
			wave_ui.hide_ready_button()

func _physics_process(delta: float) -> void:
	if is_spawning_phase:
		run_spawning_phase(delta)
	else:
		run_intermission_phase(delta)

# --- SPAWNING PHASE ---
func run_spawning_phase(delta: float) -> void:
	if bugs_spawned_this_wave < Variables.bugs_per_wave:
		spawn_timer += delta
		if spawn_timer >= Variables.spawn_delay:
			spawn_timer = 0.0
			spawn_bug_offscreen()
			bugs_spawned_this_wave += 1
	else:
		check_wave_cleared()

func check_wave_cleared() -> void:
	if get_active_bug_count() <= 0:
		is_spawning_phase = false
		wave_timer = 0.0
		if wave_ui:
			wave_ui.show_timer()
			if wave_ui.has_method("show_ready_button"):
				wave_ui.show_ready_button()

func get_active_bug_count() -> int:
	var count: int = 0
	for child in get_children():
		if child is CharacterBody2D:
			count += 1
	return count

# --- INTERMISSION PHASE ---
func run_intermission_phase(delta: float) -> void:
	wave_timer += delta
	var time_left = max(0.0, Variables.wave_break_time - wave_timer)
	
	if wave_ui:
		wave_ui.update_timer_text(time_left)
		
	if wave_timer >= Variables.wave_break_time:
		start_next_wave()

func start_next_wave() -> void:
	Variables.current_wave += 1
	Variables.bugs_per_wave += 3
	bugs_spawned_this_wave = 0
	wave_timer = 0.0
	is_spawning_phase = true
	
	if wave_ui:
		wave_ui.update_wave_text(Variables.current_wave)
		wave_ui.hide_timer()
		if wave_ui.has_method("hide_ready_button"):
			wave_ui.hide_ready_button()

func _on_ready_button_pressed() -> void:
	if not is_spawning_phase:
		start_next_wave()

# --- SPAWN MATH ---
func spawn_bug_offscreen() -> void:
	var screen_size = get_viewport().size
	var spawn_pos = Vector2.ZERO
	var side = randi_range(1, 4)
	var margin = Variables.spawn_margin
	
	if side == 1:   # TOP
		spawn_pos.x = randf_range(0, screen_size.x)
		spawn_pos.y = -margin
	elif side == 2: # BOTTOM
		spawn_pos.x = randf_range(0, screen_size.x)
		spawn_pos.y = screen_size.y + margin
	elif side == 3: # LEFT
		spawn_pos.x = -margin
		spawn_pos.y = randf_range(0, screen_size.y)
	elif side == 4: # RIGHT
		spawn_pos.x = screen_size.x + margin
		spawn_pos.y = randf_range(0, screen_size.y)
		
	var bug = basic_bug.instantiate()
	add_child(bug)
	bug.global_position = spawn_pos
