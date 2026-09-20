extends Node2D

const SCRAP_SCENE = preload("res://Scenes/World/ScrapItem.tscn")

signal ammo_emptied
signal ammo_changed
signal reload_started
signal reload_finished

@export var damage: float = 15.0
@export var reload_time: float = 2.0
@export var calm_delay: float = 0.75

@onready var attack_range: Area2D = $Range
@onready var cooldown: Timer = $Cooldown
@onready var reload: Timer = $Reload

var gun_is_cool: bool = true
var is_reloading: bool = false
var ammo_limit: int = 20
var ammo: int = ammo_limit
var threat_timer: float = 0.0


func _ready() -> void:
	# Stop firing when the game is paused (e.g., in Workshop)
	process_mode = Node.PROCESS_MODE_PAUSABLE

	ammo_limit = Variables.gun_ammo_limit
	ammo = ammo_limit
	
	cooldown.one_shot = true
	cooldown.wait_time = Variables.gun_cooldown
	cooldown.timeout.connect(func(): gun_is_cool = true)
	
	reload.one_shot = true
	reload.wait_time = reload_time
	if reload.timeout and not reload.timeout.is_connected(_on_reload_timeout):
		reload.timeout.connect(_on_reload_timeout)
	
	if Variables.has_signal("upgrades_updated"):
		Variables.upgrades_updated.connect(_on_upgrades_updated)
	
	ammo_emptied.connect(_on_ammo_emptied)
	ammo_changed.emit()


func _on_upgrades_updated() -> void:
	cooldown.wait_time = Variables.gun_cooldown


func _physics_process(delta: float) -> void:
	threat_timer = calm_delay if is_any_bug_on_screen() else maxf(0.0, threat_timer - delta)
	
	if gun_is_cool and ammo > 0 and not is_reloading:
		try_to_shoot()

func try_to_shoot() -> void:
	var bodies = attack_range.get_overlapping_bodies()
	if bodies.is_empty():
		return

	var enemy = get_closest_target(bodies, "Enemies")
	if enemy:
		_execute_shot(enemy)
	elif threat_timer <= 0.0:
		var rock = get_closest_target(bodies, "Minable")
		if rock:
			_execute_shot(rock)


func _execute_shot(target: Node2D) -> void:
	gun_is_cool = false
	cooldown.start(Variables.gun_cooldown)

	if target.is_in_group("Enemies"):
		var scrap = SCRAP_SCENE.instantiate()
		scrap.global_position = target.global_position
		get_tree().current_scene.add_child(scrap)
		target.queue_free()
		
		ammo = maxi(0, ammo - 1)
		ammo_changed.emit()
		if ammo == 0:
			ammo_emptied.emit()
			
	elif target.is_in_group("Minable") and target.has_method("take_damage"):
		# Uses active pickaxe damage
		target.take_damage(Variables.pickaxe_damage)


func _on_ammo_emptied() -> void:
	if is_reloading:
		return
	is_reloading = true
	reload_started.emit()
	reload.start()


func _on_reload_timeout() -> void:
	ammo = ammo_limit
	is_reloading = false
	ammo_changed.emit()
	reload_finished.emit()


func get_closest_target(bodies: Array, group: String) -> Node2D:
	var closest: Node2D = null
	var min_dist_sq: float = INF
	for body in bodies:
		if is_instance_valid(body) and body.is_in_group(group):
			var dist_sq = global_position.distance_squared_to(body.global_position)
			if dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				closest = body
	return closest


func is_any_bug_on_screen() -> bool:
	var vp = get_viewport()
	if not vp:
		return false
	
	var rect = vp.get_visible_rect()
	var xform = vp.get_canvas_transform()
	
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		if is_instance_valid(enemy) and enemy is Node2D and rect.has_point(xform * enemy.global_position):
			return true
	return false
