extends CharacterBody2D

var last_direction: Vector2 = Vector2.ZERO
var player_speed = Variables.player_speed

func _process(delta):
	var direction: Vector2 = Vector2.ZERO
	#getting direction
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	velocity = direction * player_speed
	
	move_and_slide()
	
	if direction.length() > 0:
		var last_direction = direction.normalized()
		rotation = last_direction.angle()
		


func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemies"):
		body.queue_free()
		print("abcd")
