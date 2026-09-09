extends Node2D

const ORE_SCENE = preload("res://Scenes/World/Ore.tscn")

@export_group("Seed & Randomness")
@export var use_custom_seed: bool = false
@export var world_seed: String = "jatin_2026"

@export_group("World Geometry")
@export var tile_size: float = 48.0
@export var safe_radius_pixels: float = 220.0   # Clear circle around the house
@export var position_jitter: float = 3.0

@export_group("Cluster Balance")
@export var number_of_clusters: int = 14        # Total separate ore patches across the screen
@export var min_ores_per_cluster: int = 4
@export var max_ores_per_cluster: int = 9
@export_range(0.0, 1.0) var iron_ratio: float = 0.28  # ~28% of ores spawned will be Iron

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

var current_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var spawned_tiles: Dictionary = {} # Vector2i -> int (1: Stone, 2: Iron)


func _ready() -> void:
	# Call deferred to ensure the House node is fully loaded in the tree
	call_deferred("_initialize_generation")


func _setup_rng() -> void:
	if use_custom_seed and world_seed != "":
		current_rng.seed = world_seed.hash()
	else:
		current_rng.randomize()


func _initialize_generation() -> void:
	_setup_rng()
	generate_screen_world()


func generate_screen_world() -> void:
	for c in get_children():
		c.queue_free()
	spawned_tiles.clear()

	# 1. Resolve House Center Position
	var house = get_tree().get_first_node_in_group("House")
	var center_pos: Vector2
	if is_instance_valid(house):
		center_pos = house.global_position
	else:
		var vp_rect = get_viewport_rect()
		center_pos = vp_rect.size * 0.5

	# 2. Determine Visible Screen Bounds
	var vp = get_viewport_rect()
	var padding = 60.0
	var min_x = padding
	var max_x = vp.size.x - padding
	var min_y = padding + 40.0 # extra top padding for UI bar
	var max_y = vp.size.y - padding

	# 3. Generate Distinct Balanced Clusters
	var clusters_placed = 0
	var attempts = 0
	
	while clusters_placed < number_of_clusters and attempts < 200:
		attempts += 1
		
		# Pick a random cluster origin point across the entire screen
		var cluster_origin = Vector2(
			current_rng.randf_range(min_x, max_x),
			current_rng.randf_range(min_y, max_y)
		)

		# Reject if too close to the house
		if cluster_origin.distance_to(center_pos) < safe_radius_pixels + 50.0:
			continue

		# Build an organic blob cluster around this origin
		_grow_cluster(cluster_origin, center_pos)
		clusters_placed += 1

	# 4. Instantiate Ore Objects
	_instantiate_ores(center_pos)


func _grow_cluster(origin: Vector2, center_pos: Vector2) -> void:
	var base_cell = Vector2i(round(origin.x / tile_size), round(origin.y / tile_size))
	var cluster_size = current_rng.randi_range(min_ores_per_cluster, max_ores_per_cluster)

	var frontier: Array[Vector2i] = [base_cell]
	var cluster_cells: Array[Vector2i] = []

	while cluster_cells.size() < cluster_size and not frontier.is_empty():
		frontier.shuffle()
		var current = frontier.pop_back()

		var world_p = Vector2(current) * tile_size
		if world_p.distance_to(center_pos) < safe_radius_pixels:
			continue

		if not spawned_tiles.has(current):
			cluster_cells.append(current)
			spawned_tiles[current] = 1 # Default to Stone

			# Add 4-directional neighbors to frontier for natural grouping
			var neighbors = [
				current + Vector2i.RIGHT,
				current + Vector2i.LEFT,
				current + Vector2i.UP,
				current + Vector2i.DOWN
			]
			for n in neighbors:
				if not spawned_tiles.has(n) and not frontier.has(n):
					frontier.append(n)

	# Designate deep or central cluster cores as Iron
	for cell in cluster_cells:
		if current_rng.randf() < iron_ratio:
			spawned_tiles[cell] = 2


func _instantiate_ores(center_pos: Vector2) -> void:
	for cell in spawned_tiles.keys():
		var tile_type = spawned_tiles[cell]
		var jitter = Vector2(
			current_rng.randf_range(-position_jitter, position_jitter),
			current_rng.randf_range(-position_jitter, position_jitter)
		)
		var world_pos = (Vector2(cell) * tile_size) + jitter

		# Strict safety cutoff: never allow an ore within safe radius
		if world_pos.distance_to(center_pos) < safe_radius_pixels:
			continue

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

		add_child(rock)


func regenerate() -> void:
	_initialize_generation()
