extends Node2D

const SCRAP_SCENE = preload("res://Scenes/ScrapItem.tscn")

@onready var attack_range: Area2D = $Range
@onready var cooldown: Timer = $Cooldown

var gun_is_cool: bool
var enemies_in_range: Array

func _ready() -> void:
	gun_is_cool = true
	cooldown.one_shot = true
	cooldown.wait_time = Variables.gun_cooldown
	
	if Variables.has_signal("upgrades_updated"):
		Variables.upgrades_updated.connect(_on_upgrades_updated)

func _on_upgrades_updated() -> void:
	cooldown.wait_time = Variables.gun_cooldown

func _on_cooldown_timeout() -> void:
	gun_is_cool = true
	try_to_shoot()

func _on_body_entered_in_range(_body: Node2D) -> void:
	call_deferred("try_to_shoot")

func sort_by_distance(a: Node2D, b: Node2D) -> bool:
	var dist_a = a.global_position.distance_squared_to(global_position)
	var dist_b = b.global_position.distance_squared_to(global_position)
	return dist_a < dist_b

func try_to_shoot() -> void:
	if not gun_is_cool:
		return
	
	enemies_in_range = attack_range.get_overlapping_bodies()
	if enemies_in_range.is_empty():
		return
	
	enemies_in_range.sort_custom(sort_by_distance)
	
	# Priority 1: Check for real enemies first
	for target in enemies_in_range:
		if is_instance_valid(target) and not target.is_in_group("Minable") and not target.is_in_group("Player"):
			look_at(target.global_position)
			
			var scrap_drop = SCRAP_SCENE.instantiate()
			scrap_drop.global_position = target.global_position
			get_tree().current_scene.add_child(scrap_drop)
			
			target.queue_free()
			print("Enemy killed!")
			
			cooldown.start()
			gun_is_cool = false
			return
	
	# Priority 2: If no enemies were found, mine the nearest rock
	for target in enemies_in_range:
		if is_instance_valid(target) and target.is_in_group("Minable"):
			look_at(target.global_position)
			
			if target.has_method("take_damage"):
				target.take_damage(1)
			
			cooldown.start()
			gun_is_cool = false
			return
