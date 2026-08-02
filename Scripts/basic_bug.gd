extends CharacterBody2D

@onready var house: Node2D = %house

var house_position: Vector2 = Vector2.ZERO
@export var bug_speed = 200


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	house_position = house.global_position
	print(house_position)
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position = position.move_toward(house_position, bug_speed*delta)
	pass
