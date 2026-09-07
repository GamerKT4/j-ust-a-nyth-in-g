extends CharacterBody2D

@onready var house: Node2D = get_node("/root/Main/World/house")
@onready var h_slider: HSlider = get_node("/root/Main/Bug_speed_slider")

var house_position: Vector2 = Vector2.ZERO
var bug_speed = Variables.bug_speed


func _ready() -> void:
	house_position = house.global_position
	pass 


func _physics_process(delta):
	position = position.move_toward(house_position, bug_speed*delta)
	bug_speed = h_slider.value
	
