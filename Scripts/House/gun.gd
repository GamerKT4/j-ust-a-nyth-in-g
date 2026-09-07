extends Node2D

const SCRAP_SCENE = preload("res://Scenes/World/ScrapItem.tscn")

signal ammo_emptied
signal ammo_changed
signal reload_started
signal reload_finished

@onready var attack_range: Area2D = $Range
@onready var cooldown: Timer = $Cooldown
@onready var reload: Timer = $Reload

# Visual references
@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

var gun_is_cool: bool = true
var is_reloading: bool = false
var ammo_limit: int = 10
var ammo: int = ammo_limit

@export var damage: float = 15.0
@export var reload_time: float = 2.0 # Default reload duration in seconds
@export var calm_delay: float = 0.75 # Seconds before resuming mining after bugs leave screen

var threat_timer: float = 0.0


func _ready() -> void:
	if "gun_ammo_limit" in Variables:
		ammo_limit = Variables.gun_ammo_limit
	ammo = ammo_limit
	
	gun_is_cool = true
	is_reloading = false
	
	# Configure Timers
	cooldown.one_shot = true
	cooldown.wait_time = Variables.gun_cooldown
	
	reload.one_shot = true
	if "gun_reload_time" in Variables:
		reload.wait_time = Variables.gun_reload_time
	else:
		reload.wait_time = reload_time
	
	# Connect Timer Signals Safely
	if not cooldown.timeout.is_connected(_on_cooldown_timeout):
		cooldown.timeout.connect(_on_cooldown_timeout)
	if not reload.timeout.is_connected(_on_reload_timeout):
		reload.timeout.connect(_on_reload_timeout)
	
	rotation = 0.0
	scale = Vector2.ONE
	
	if Variables.has_signal("upgrades_updated"):
		Variables.upgrades_updated.connect(_on_upgrades_updated)
	
	ammo_emptied.connect(_on_ammo_emptied)
	
	# Notify UI of initial full ammo
	ammo_changed.emit()


func _process(delta: float) -> void:
	# Check if any enemy is on screen
	if is_any_bug_on_screen():
		threat_timer = calm_delay # Reset wait timer while bugs are visible
	elif threat_timer > 0.0:
		threat_timer -= delta # Count down when screen is clear
	
	# Cannot shoot while cooling down, out of ammo, or reloading
	if gun_is_cool and ammo > 0 and not is_reloading:
		try_to_shoot()


func try_to_shoot() -> void:
	var bodies = attack_range.get_overlapping_bodies()
	if bodies.is_empty():
		return

	# Priority 1: Shoot nearest bug inside gun attack radius
	var nearest_enemy: Node2D = get_closest_target_in_group(bodies, "Enemies")
	if nearest_enemy:
		_execute_shot(nearest_enemy)
		return

	# Priority 2: If bugs are on screen or threat timer is active, hold fire and DO NOT mine
	if threat_timer > 0.0:
		return

	# Priority 3: Screen has been clear for calm_delay -> mine nearest rock
	var nearest_rock: Node2D = get_closest_target_in_group(bodies, "Minable")
	if nearest_rock:
		_execute_shot(nearest_rock)


func _execute_shot(target: Node2D) -> void:
	_play_shoot_animation()

	if target.is_in_group("Enemies"):
		var scrap_drop = SCRAP_SCENE.instantiate()
		scrap_drop.global_position = target.global_position
		get_tree().current_scene.add_child(scrap_drop)
		
		target.queue_free()
		ammo -= 1
		ammo_changed.emit()
		
		cooldown.start()
		gun_is_cool = false
		
		if ammo <= 0:
			ammo = 0
			ammo_emptied.emit()

	elif target.is_in_group("Minable"):
		if target.has_method("take_damage"):
			var dmg = Variables.pickaxe_damage if "pickaxe_damage" in Variables else 1
			target.take_damage(dmg)
		
		cooldown.start()
		gun_is_cool = false


func _play_shoot_animation() -> void:
	if anim_player and anim_player.has_animation("shoot"):
		anim_player.stop()
		anim_player.play("shoot")
	elif anim_sprite and anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("shoot"):
		anim_sprite.stop()
		anim_sprite.play("shoot")


func _play_reload_animation() -> void:
	if anim_player and anim_player.has_animation("reload"):
		anim_player.play("reload")
	elif anim_sprite and anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("reload"):
		anim_sprite.play("reload")


func _on_upgrades_updated() -> void:
	cooldown.wait_time = Variables.gun_cooldown


func _on_cooldown_timeout() -> void:
	gun_is_cool = true


func _on_ammo_emptied() -> void:
	if is_reloading:
		return
	is_reloading = true
	reload_started.emit()
	_play_reload_animation()
	reload.start()


func _on_reload_timeout() -> void:
	ammo = ammo_limit
	is_reloading = false
	ammo_changed.emit()
	reload_finished.emit()


# Fast single-pass search for the closest body in a specific group
func get_closest_target_in_group(bodies: Array, group_name: String) -> Node2D:
	var closest: Node2D = null
	var min_dist_sq: float = INF
	
	for body in bodies:
		if is_instance_valid(body) and body.is_in_group(group_name):
			var dist_sq = global_position.distance_squared_to(body.global_position)
			if dist_sq < min_dist_sq:
				min_dist_sq = dist_sq
				closest = body
				
	return closest


# Checks if any enemy is currently visible inside the camera's viewport
func is_any_bug_on_screen() -> bool:
	var viewport = get_viewport()
	if not viewport:
		return false
		
	var screen_rect = viewport.get_visible_rect()
	var canvas_xform = viewport.get_canvas_transform()
	var enemies = get_tree().get_nodes_in_group("Enemies")
	
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy is Node2D:
			var screen_pos = canvas_xform * enemy.global_position
			if screen_rect.has_point(screen_pos):
				return true
				
	return false
