extends CharacterBody2D

var direction: Vector2 = Vector2.ZERO
var player_speed = Variables.player_speed

func _process(delta):
	
	#getting direction
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	velocity = direction * player_speed
	
	move_and_slide()
