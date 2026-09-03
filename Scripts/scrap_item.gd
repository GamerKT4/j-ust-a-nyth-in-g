extends Area2D

@export var value: int = 1
@export var magnet_speed: float = 360.0
@export var pickup_distance: float = 16.0

@onready var visual: ColorRect = $ColorRect

var player: CharacterBody2D = null
var is_collected: bool = false
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	_spawn_bounce()

func _spawn_bounce() -> void:
	var pop_target = global_position + Vector2.RIGHT.rotated(randf_range(0.0, TAU)) * randf_range(10.0, 20.0)
	var t = create_tween()
	t.tween_property(self, "global_position", pop_target, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _physics_process(delta: float) -> void:
	if is_collected or not is_instance_valid(player):
		return

	var dist_sq: float = global_position.distance_squared_to(player.global_position)
	var magnet_range_sq: float = Variables.player_magnet_range * Variables.player_magnet_range
	var pickup_distance_sq: float = pickup_distance * pickup_distance

	# Accelerate toward player when inside magnet radius
	if dist_sq < magnet_range_sq:
		var dir: Vector2 = (player.global_position - global_position).normalized()
		velocity = velocity.move_toward(dir * magnet_speed, 1200.0 * delta)
		global_position += velocity * delta

		# Picked up
		if dist_sq < pickup_distance_sq:
			_collect()

func _collect() -> void:
	is_collected = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Safe economy update
	if Variables.has_method("add_resource"):
		Variables.add_resource("scrap", value)
	elif Variables.has_method("add_scrap"):
		Variables.add_scrap(value)

	# Elastic shrink absorption
	var t = create_tween()
	t.tween_property(self, "scale", Vector2.ZERO, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	t.tween_callback(queue_free)
