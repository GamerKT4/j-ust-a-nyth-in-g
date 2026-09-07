extends Node2D

const ORE_SCENE = preload("res://Scenes/World/Ore.tscn")

@export_group("Seed & Randomness")
@export var use_custom_seed: bool = false
@export var world_seed: String = "jatin_2026"

@export_group("World Boundaries")
@export var map_radius: int = 35
@export var tile_size: float = 48.0
@export var safe_radius: int = 8
@export var position_jitter: float = 6.0

@export_group("Cellular Automata (Cave Generation)")
@export_range(0.0, 1.0) var initial_fill_percent: float = 0.36
@export var smoothing_iterations: int = 5
@export var wall_birth_limit: int = 4
@export var wall_death_limit: int = 3

@export_group("Geological Injection")
@export var core_depth_requirement: int = 7
@export_range(0.0, 1.0) var iron_core_chance: float = 0.18

@export_group("Ore Assets & Stats")
@export_subgroup("Stone")
@export var stone_texture: Texture2D
@export var stone_hp: int = 3
@export var stone_color: Color = Color.WHITE
@export var stone_scale: Vector2 = Vector2(0.9, 0.9)

@export_subgroup("Iron")
@export var iron_texture: Texture2D
@export var iron_hp: int = 6
@export var iron_color: Color = Color.WHITE
@export var iron_scale: Vector2 = Vector2(1.1, 1.1)

@export_subgroup("Bedrock")
@export var bedrock_texture: Texture2D
@export var bedrock_color: Color = Color(0.4, 0.4, 0.45)

var grid_map: Dictionary = {}
var current_rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_setup_rng()
	_generate_world()

func _setup_rng() -> void:
	if use_custom_seed and world_seed != "":
		current_rng.seed = world_seed.hash()
	else:
		current_rng.randomize()

func _generate_world() -> void:
	_pass_1_random_fill()
	for i in range(smoothing_iterations):
		_pass_2_cellular_smoothing()
	_pass_3_geological_injection()
	_pass_4_arena_perimeter()
	_pass_5_instantiate_world()

func _pass_1_random_fill() -> void:
	grid_map.clear()
	var safe_r_sq = safe_radius * safe_radius
	
	for x in range(-map_radius, map_radius + 1):
		for y in range(-map_radius, map_radius + 1):
			var cell = Vector2(x, y)
			if cell.length_squared() <= safe_r_sq:
				grid_map[cell] = 0
			else:
				grid_map[cell] = 1 if current_rng.randf() < initial_fill_percent else 0

func _pass_2_cellular_smoothing() -> void:
	var next_grid = grid_map.duplicate()
	for x in range(-map_radius, map_radius + 1):
		for y in range(-map_radius, map_radius + 1):
			var cell = Vector2(x, y)
			var rock_neighbors = _get_surrounding_rock_count(cell)
			
			if grid_map.get(cell, 0) == 1:
				if rock_neighbors < wall_death_limit:
					next_grid[cell] = 0
				else:
					next_grid[cell] = 1
			else:
				if rock_neighbors > wall_birth_limit:
					next_grid[cell] = 1
				else:
					next_grid[cell] = 0
	grid_map = next_grid

func _pass_3_geological_injection() -> void:
	var next_grid = grid_map.duplicate()
	for x in range(-map_radius, map_radius + 1):
		for y in range(-map_radius, map_radius + 1):
			var cell = Vector2(x, y)
			
			if grid_map.get(cell, 0) == 1:
				var rock_neighbors = _get_surrounding_rock_count(cell)
				if rock_neighbors >= core_depth_requirement:
					if current_rng.randf() < iron_core_chance:
						next_grid[cell] = 2
	grid_map = next_grid

func _pass_4_arena_perimeter() -> void:
	for x in range(-map_radius - 1, map_radius + 2):
		for y in [-map_radius - 1, map_radius + 1]:
			grid_map[Vector2(x, y)] = 3
	for y in range(-map_radius - 1, map_radius + 2):
		for x in [-map_radius - 1, map_radius + 1]:
			grid_map[Vector2(x, y)] = 3

func _pass_5_instantiate_world() -> void:
	for cell in grid_map:
		var tile_type = grid_map[cell]
		if tile_type == 0:
			continue
			
		var jitter = Vector2(
			current_rng.randf_range(-position_jitter, position_jitter),
			current_rng.randf_range(-position_jitter, position_jitter)
		)
		
		if tile_type == 3:
			jitter = Vector2.ZERO
			
		var world_pos = (cell * tile_size) + jitter
		var rock = ORE_SCENE.instantiate()
		rock.global_position = world_pos
		
		match tile_type:
			1: # Stone
				rock.ore_type = "stone"
				rock.max_hp = stone_hp
				rock.base_color = stone_color
				rock.scale = stone_scale
				if stone_texture and rock.has_method("set_texture"):
					rock.set_texture(stone_texture)
				rock.add_to_group("Minable")
			2: # Iron
				rock.ore_type = "iron"
				rock.max_hp = iron_hp
				rock.base_color = iron_color
				rock.scale = iron_scale
				if iron_texture and rock.has_method("set_texture"):
					rock.set_texture(iron_texture)
				rock.add_to_group("Minable")
			3: # Bedrock Border
				rock.ore_type = "bedrock"
				rock.max_hp = 99999
				rock.base_color = bedrock_color
				rock.scale = Vector2.ONE
				if bedrock_texture and rock.has_method("set_texture"):
					rock.set_texture(bedrock_texture)
				
		add_child(rock)

func _get_surrounding_rock_count(cell: Vector2) -> int:
	var count = 0
	for nx in range(-1, 2):
		for ny in range(-1, 2):
			if nx == 0 and ny == 0:
				continue
				
			var neighbor = cell + Vector2(nx, ny)
			if neighbor.x < -map_radius or neighbor.x > map_radius or neighbor.y < -map_radius or neighbor.y > map_radius:
				count += 1
			elif grid_map.get(neighbor, 0) > 0:
				count += 1
	return count

func regenerate() -> void:
	for c in get_children():
		c.queue_free()
	_setup_rng()
	_generate_world()
