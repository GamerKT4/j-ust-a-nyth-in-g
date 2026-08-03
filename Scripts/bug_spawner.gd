extends Node

var basic_bug = preload("res://Scenes/basic_bug.tscn")

var viewport_size: Vector2
var random_cords: Vector2
var upper_limit: Vector2
var lower_limit: Vector2
func _ready() -> void:
	viewport_size = get_viewport().size 
	upper_limit = Vector2(viewport_size.x - 36, viewport_size.y - 36)
	lower_limit = Vector2(36, 36)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	random_cords.x = randf_range(lower_limit.x, upper_limit.x)
	random_cords.y = randf_range(lower_limit.y, upper_limit.y)
	
	var bug = basic_bug.instantiate()
	add_child(bug)
	bug.position = Vector2(random_cords.x, random_cords.y)
