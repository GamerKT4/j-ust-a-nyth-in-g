extends CharacterBody2D

var last_direction: Vector2 = Vector2.DOWN

@export var mining_reach: float = 140.0
@export var pickaxe_damage: int = 1

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	
	# Getting input direction
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	# Read directly from Variables so speed upgrades apply instantly
	velocity = direction.normalized() * Variables.player_speed
	move_and_slide()
	
	# Update facing angle when moving
	if direction.length() > 0:
		last_direction = direction.normalized()
		rotation = last_direction.angle()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body.queue_free()
		print("abcd")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_mine_at_cursor()

func _try_mine_at_cursor() -> void:
	var mouse_pos = get_global_mouse_position()
	
	if global_position.distance_to(mouse_pos) > mining_reach:
		return
	
	var space_state = get_world_2d().direct_space_state
	var point_params = PhysicsPointQueryParameters2D.new()
	point_params.position = mouse_pos
	point_params.collide_with_areas = true
	point_params.collide_with_bodies = true
	
	var results = space_state.intersect_point(point_params, 8)
	for hit in results:
		var collider = hit.collider
		if is_instance_valid(collider) and collider.is_in_group("Minable"):
			if collider.has_method("take_damage"):
				collider.take_damage(pickaxe_damage)
				return
