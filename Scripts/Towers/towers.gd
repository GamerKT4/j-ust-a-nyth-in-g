extends Node2D

var machine_gun_tower = preload("res://Scenes/Towers/machine_gun_tower.tscn")
@onready var shop_menu: CanvasLayer = $"../ShopMenu"

var is_tower_placed: bool = true
var gun_tower: Node2D

func on_tower_purchased():
	var stone = Variables.inventory.get("stone", 0)
	var scrap = Variables.inventory.get("scrap", 0)
	var iron = Variables.inventory.get("iron", 0)
	
	if stone >= 5 and iron >= 5 and scrap >= 5:
		Variables.spend_resource("stone", 5)
		Variables.spend_resource("scrap", 5)
		Variables.spend_resource("iron", 5)
	else:
		return
	
	gun_tower = machine_gun_tower.instantiate()
	shop_menu.visible = false
	is_tower_placed = false

func _physics_process(_delta):
	if Input.is_action_just_pressed("left_mouse_button") and is_tower_placed == false and shop_menu.visible == false:
		is_tower_placed = true
		var tower_position = get_global_mouse_position()
		add_child(gun_tower)
		gun_tower.position = tower_position
		get_tree().paused = false
		print("Tower placed.")
