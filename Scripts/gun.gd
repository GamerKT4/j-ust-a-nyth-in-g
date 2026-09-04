extends Node2D

const SCRAP_SCENE = preload("res://Scenes/ScrapItem.tscn")

@export var damage: float = 15.0

@onready var attack_range: Area2D = $Range
@onready var cooldown: Timer = $Cooldown

var gun_is_cool: bool = true

func _ready() -> void:
	gun_is_cool = true
	cooldown.one_shot = true
	cooldown.wait_time = Variables.gun_cooldown
	
	if Variables.has_signal("upgrades_updated"):
		Variables.upgrades_updated.connect(_on_upgrades_updated)

func _on_upgrades_updated() -> void:
	cooldown.wait_time = Variables.gun_cooldown

func _physics_process(_delta: float) -> void:
	if gun_is_cool:
		try_to_shoot()

func sort_by_distance(a: Node2D, b: Node2D) -> bool:
	var dist_a = a.global_position.distance_squared_to(global_position)
	var dist_b = b.global_position.distance_squared_to(global_position)
	return dist_a < dist_b

func try_to_shoot() -> void:
	var targets = attack_range.get_overlapping_bodies()
	if targets.is_empty():
		return
	
	var enemies: Array[Node2D] = []
	for body in targets:
		if is_instance_valid(body) and not body.is_in_group("Player") and not body.is_in_group("Minable"):
			enemies.append(body)
			
	if enemies.is_empty():
		return
		
	enemies.sort_custom(sort_by_distance)
	var target = enemies[0]
	
	gun_is_cool = false
	cooldown.start(Variables.gun_cooldown)
	
	if target.has_method("take_damage"):
		target.take_damage(damage)
	elif "health" in target:
		target.health -= damage
		if target.health <= 0:
			_spawn_scrap(target.global_position)
			target.queue_free()
	else:
		_spawn_scrap(target.global_position)
		target.queue_free()

func _spawn_scrap(pos: Vector2) -> void:
	var scrap_drop = SCRAP_SCENE.instantiate()
	scrap_drop.global_position = pos
	get_tree().current_scene.add_child(scrap_drop)

func _on_cooldown_timeout() -> void:
	gun_is_cool = true
