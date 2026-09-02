extends Area2D

@export var value: int = 1
@export var magnet_speed: float = 280.0
@export var pickup_distance: float = 16.0
@export var magnet_range: float = 120.0

var player: CharacterBody2D = null

func _ready() -> void:
	# Looks for the player node in the "Player" group
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	# Fly toward the player when in range
	if dist < magnet_range:
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * magnet_speed * delta
		
		# Picked up when touching
		if dist < pickup_distance:
			Variables.add_scrap(value)
			queue_free()
