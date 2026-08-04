extends CharacterBody2D

@onready var house: Node2D = get_node("/root/Main/World/house")

var house_position: Vector2 = Vector2.ZERO
@export var bug_speed = 200


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	house_position = house.global_position
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position = position.move_toward(house_position, bug_speed*delta)
	


func _on_h_slider_value_changed(value):
	print(value)
	
