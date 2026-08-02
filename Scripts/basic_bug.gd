extends CharacterBody2D

## Speed of the bug in pixels per second
@export var bug_speed: float = 200.0

## Distance in pixels at which the bug considers itself "arrived"
@export var arrival_threshold: float = 5.0

## Speed at which the bug turns toward the target (higher = faster turns)
@export var rotation_speed: float = 10.0

## Reference to the house node using Unique Name (%house)
@onready var house: Node2D = %house


func _physics_process(delta: float) -> void:
	# Safety check: ensure house exists in the scene
	if not is_instance_valid(house):
		return

	# Always get current global position (works even if house or bug is nested in another node)
	var house_position: Vector2 = house.global_position
	var distance_to_house: float = global_position.distance_to(house_position)

	if distance_to_house > arrival_threshold:
		# Calculate direction toward target
		var target_direction: Vector2 = global_position.direction_to(house_position)
		
		# Set movement velocity
		velocity = target_direction * bug_speed
		
		# Smoothly rotate bug to face movement direction (assumes sprite faces Right by default)
		var target_angle: float = target_direction.angle()
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	else:
		# Stop bug when it reaches the house
		velocity = Vector2.ZERO

	# Move using physics engine
	move_and_slide()
