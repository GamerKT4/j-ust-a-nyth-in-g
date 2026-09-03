extends Node2D

const ORE_SCENE = preload("res://Scenes/Ore.tscn")

@export_group("Seed & Randomness")
@export var world_seed: int = 0
@export var randomize_seed_on_start: bool = true

@export_group("World Boundaries & Grid")
@export var map_radius: int = 35           # Grid extends from -35 to +35
@export var tile_size: float = 48.0        # Base distance between points
@export var safe_radius: float = 5.0       # Clear radius around (0, 0)
@export var position_jitter: float = 12.0  # Breaks rigid grid lines into organic clusters

@export_group("Noise Configuration")
@export var vein_frequency: float = 0.08
@export var density_frequency: float = 0.02
@export_range(0.0, 1.0) var global_density_threshold: float = 0.35 # Clearings vs rock zones

@export_group("Ore Definitions")
# Sorted descending by threshold in code. Configure anything right inside the Inspector!
@export var ore_definitions: Array[Dictionary] = [
	{
		"type": "iron",
		"threshold": 0.62,
		"hp": 5,
		"color": Color(0.88, 0.45, 0.22),
		"scale_range": Vector2(0.95, 1.15)
	},
	{
		"type": "stone",
		"threshold": 0.30,
		"hp": 3,
		"color": Color(0.68, 0.70, 0.74),
		"scale_range": Vector2(0.85, 1.1)
	}
]

var vein_noise: FastNoiseLite = FastNoiseLite.new()
var density_noise: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	if randomize_seed_on_start and world_seed == 0:
		randomize()
		world_seed = randi()
	
	_setup_noise()
	_generate_world()

func _setup_noise() -> void:
	# Vein cluster noise
	vein_noise.seed = world_seed
	vein_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	vein_noise.frequency = vein_frequency
	
	# Density/clearing mask noise (second layer for organic empty pathways)
	density_noise.seed = world_seed + 101
	density_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	density_noise.frequency = density_frequency

func _generate_world() -> void:
	var safe_radius_sq: float = safe_radius * safe_radius
	
	# Sort definitions descending so highest rarity threshold is checked first
	var sorted_ores = ore_definitions.duplicate()
	sorted_ores.sort_custom(func(a, b): return a["threshold"] > b["threshold"])
	
	for x in range(-map_radius, map_radius + 1):
		for y in range(-map_radius, map_radius + 1):
			var grid_coord = Vector2(x, y)
			
			# Fast distance-squared check for center clear zone
			if grid_coord.length_squared() < safe_radius_sq:
				continue
			
			# Check density noise mask to create open fields and corridors
			var density_val = (density_noise.get_noise_2d(float(x), float(y)) + 1.0) * 0.5
			if density_val < global_density_threshold:
				continue
			
			var n: float = vein_noise.get_noise_2d(float(x), float(y))
			
			# Match against ore thresholds
			for ore in sorted_ores:
				if n >= ore["threshold"]:
					var jitter = Vector2(
						randf_range(-position_jitter, position_jitter),
						randf_range(-position_jitter, position_jitter)
					)
					var world_pos = (grid_coord * tile_size) + jitter
					_spawn_rock(ore, world_pos)
					break

func _spawn_rock(data: Dictionary, pos: Vector2) -> void:
	var rock = ORE_SCENE.instantiate()
	rock.ore_type = data.get("type", "stone")
	rock.max_hp = data.get("hp", 3)
	rock.base_color = data.get("color", Color.WHITE)
	rock.global_position = pos
	
	# Natural scale variety
	var scale_range: Vector2 = data.get("scale_range", Vector2.ONE)
	var random_scale = randf_range(scale_range.x, scale_range.y)
	rock.scale = Vector2(random_scale, random_scale)
	
	add_child(rock)

# Call WorldGen.regenerate(new_seed) anytime to re-roll without restarting the scene
func regenerate(new_seed: int = 0) -> void:
	for child in get_children():
		child.queue_free()
	
	world_seed = new_seed if new_seed != 0 else randi()
	_setup_noise()
	_generate_world()
