extends StaticBody2D

const PICKUP_SCENE = preload("res://Scenes/Pickup.tscn")

@export_enum("stone", "iron") var ore_type: String = "stone"
@export var max_hp: int = 3
@export var base_color: Color = Color(0.65, 0.67, 0.72)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var current_hp: int = 3
var base_scale: Vector2
var hit_tween: Tween

func _ready() -> void:
	add_to_group("Minable")
	current_hp = max_hp
	base_scale = scale
	sprite.modulate = base_color

func take_damage(amount: int = 1) -> void:
	if current_hp <= 0:
		return
		
	current_hp -= amount
	_play_hit_feedback()
	_spawn_drops(1)
	
	if current_hp <= 0:
		_shatter()

func _play_hit_feedback() -> void:
	if hit_tween and hit_tween.is_valid():
		hit_tween.kill()
		
	sprite.modulate = Color(2.0, 2.0, 2.0, 1.0) # Bright flash
	scale = Vector2(base_scale.x * 1.18, base_scale.y * 0.82) # Punchy squash
	
	hit_tween = create_tween().set_parallel(true)
	hit_tween.tween_property(sprite, "modulate", base_color, 0.14)
	hit_tween.tween_property(self, "scale", base_scale, 0.14).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _shatter() -> void:
	collision.set_deferred("disabled", true)
	_spawn_drops(2)
	
	if hit_tween and hit_tween.is_valid():
		hit_tween.kill()
		
	var death_tween = create_tween().set_parallel(true)
	death_tween.tween_property(self, "scale", Vector2.ZERO, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	death_tween.tween_property(sprite, "modulate:a", 0.0, 0.12)
	death_tween.finished.connect(queue_free)

func _spawn_drops(count: int) -> void:
	var scene = get_tree().current_scene
	for i in count:
		var drop = PICKUP_SCENE.instantiate()
		drop.resource_type = ore_type
		# Small scatter offset so multiple chunks never spawn directly on top of each other
		var offset = Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0))
		drop.global_position = global_position + offset
		scene.call_deferred("add_child", drop)
