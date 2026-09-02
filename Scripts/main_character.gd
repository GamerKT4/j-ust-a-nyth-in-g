extends CharacterBody2D

var last_direction: Vector2 = Vector2.DOWN

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
