extends Area2D

@export_enum("scrap", "stone", "iron") var resource_type: String = "stone"
@export var value: int = 1
@export var max_speed: float = 480.0
@export var pickup_radius: float = 16.0

@onready var sprite: Sprite2D = $Sprite2D

const PALETTE: Dictionary = {
	"scrap": Color(1.0, 0.84, 0.22), # Gold amber
	"stone": Color(0.72, 0.75, 0.80), # Cool slate
	"iron":  Color(0.92, 0.44, 0.20)  # Rust copper
}

var player: CharacterBody2D = null
var velocity: Vector2 = Vector2.ZERO
var is_collected: bool = false
var can_magnet: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	sprite.modulate = PALETTE.get(resource_type, Color.WHITE)
	_pop_scatter()

func _pop_scatter() -> void:
	# Pop in an arc outward, then allow magnet attraction
	var pop_dir = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	var target_pos = global_position + (pop_dir * randf_range(16.0, 28.0))
	
	var t = create_tween().set_parallel(true)
	t.tween_property(self, "global_position", target_pos, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", scale * 1.15, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.chain().tween_property(self, "scale", scale, 0.12)
	t.finished.connect(func(): can_magnet = true)

func _physics_process(delta: float) -> void:
	if is_collected or not can_magnet or not is_instance_valid(player):
		return

	var dist_sq = global_position.distance_squared_to(player.global_position)
	var magnet_range_sq = Variables.player_magnet_range * Variables.player_magnet_range
	var pickup_rad_sq = pickup_radius * pickup_radius

	if dist_sq <= magnet_range_sq:
		var dir = (player.global_position - global_position).normalized()
		
		# Smooth acceleration toward player
		velocity = velocity.move_toward(dir * max_speed, 1400.0 * delta)
		global_position += velocity * delta

		if dist_sq <= pickup_rad_sq:
			_collect()

func _collect() -> void:
	is_collected = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	Variables.add_resource(resource_type, value)
	
	# Suction pop-shrink into player
	var t = create_tween()
	t.tween_property(self, "scale", Vector2.ZERO, 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	t.tween_callback(queue_free)
