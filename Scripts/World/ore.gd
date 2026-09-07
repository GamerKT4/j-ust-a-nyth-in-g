extends StaticBody2D

const PICKUP_SCENE = preload("res://Scenes/World/pickup.tscn")

@export_enum("stone", "iron", "bedrock") var ore_type: String = "stone"
@export var max_hp: int = 3
@export var base_color: Color = Color(0.65, 0.67, 0.72)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var current_hp: int
var base_scale: Vector2
var active_tween: Tween

func _ready() -> void:
	current_hp = max_hp
	base_scale = scale
	sprite.modulate = base_color

func set_texture(new_tex: Texture2D) -> void:
	if not is_node_ready():
		await ready
	if sprite and new_tex:
		sprite.texture = new_tex

func take_damage(amount: int = 1) -> void:
	if current_hp <= 0:
		return

	current_hp -= amount
	_spawn_drops(1)

	if current_hp <= 0:
		_shatter()
	else:
		_play_hit_feedback()

func _play_hit_feedback() -> void:
	_kill_active_tween()
	
	sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
	scale = Vector2(base_scale.x * 1.18, base_scale.y * 0.82)

	active_tween = create_tween().set_parallel(true)
	active_tween.tween_property(sprite, "modulate", base_color, 0.14)
	active_tween.tween_property(self, "scale", base_scale, 0.14).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _shatter() -> void:
	collision.set_deferred("disabled", true)
	_spawn_drops(2)
	_kill_active_tween()

	active_tween = create_tween().set_parallel(true)
	active_tween.tween_property(self, "scale", Vector2.ZERO, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	active_tween.tween_property(sprite, "modulate:a", 0.0, 0.12)
	active_tween.finished.connect(queue_free)

func _spawn_drops(count: int) -> void:
	for i in count:
		var drop = PICKUP_SCENE.instantiate()
		drop.resource_type = ore_type
		drop.global_position = global_position + Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0))
		get_tree().current_scene.call_deferred("add_child", drop)

func _kill_active_tween() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
