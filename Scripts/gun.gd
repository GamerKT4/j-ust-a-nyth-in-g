extends Node2D

@onready var attack_range: Area2D = $Range
@onready var cooldown: Timer = $Cooldown

var gun_is_cool: bool
var enemies_in_range: Array

func _ready() -> void:
	gun_is_cool = true
	cooldown.one_shot = true

func _on_cooldown_timeout() -> void:
	gun_is_cool = true
	try_to_shoot()

func _on_body_entered_in_range(_body: Node2D) -> void:
	try_to_shoot()

func sort_by_distance(a, b):
	var dist_a = a.global_position.distance_squared_to(global_position)
	var dist_b = b.global_position.distance_squared_to(global_position)
	return dist_a < dist_b

func try_to_shoot():
	if not gun_is_cool:
		return
	
	enemies_in_range = attack_range.get_overlapping_bodies()
	
	if enemies_in_range.is_empty():
		return
	
	enemies_in_range.sort_custom(sort_by_distance)
	
	var closest_enemy = enemies_in_range[0]
	closest_enemy.queue_free()
	print("Enemy killed!")
	
	cooldown.start()
	gun_is_cool = false
