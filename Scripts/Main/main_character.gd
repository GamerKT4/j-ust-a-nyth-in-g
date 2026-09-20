extends CharacterBody2D

@onready var raycasts: Node2D = $Raycasts
const UPGRADE_MENU = preload("uid://bfcuot1vbvflw")

var last_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	add_to_group("Player")

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	# Instantly reflects player_speed upgrade
	velocity = direction.normalized() * Variables.player_speed
	move_and_slide()
	
	if direction.length() > 0:
		last_direction = direction.normalized()
		rotation = last_direction.angle()
	
	var colliding = false
	var rays: Array = raycasts.get_children()
	for ray in rays:
		if ray.is_colliding() and Input.is_action_just_pressed("space") and colliding == false:
			colliding = true
			print("Welcome to the shop")
			var upgrade_menu = UPGRADE_MENU.instantiate()
			get_parent().add_child(upgrade_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_mine_at_cursor()

func _try_mine_at_cursor() -> void:
	var mouse_pos = get_global_mouse_position()
	
	# Uses dynamic mining reach from Variables
	var active_reach = Variables.mining_reach
	if global_position.distance_to(mouse_pos) > active_reach:
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
				# Uses dynamic pickaxe damage from Variables
				collider.take_damage(Variables.pickaxe_damage)
				return
