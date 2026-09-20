extends CanvasLayer

@onready var towers: Node2D = %Towers

# --- WALLET LABELS ---
@export var scrap_label: Label
@export var stone_label: Label
@export var iron_label: Label

# --- UPGRADE BUTTONS ---
@export var gun_btn: Button
@export var speed_btn: Button
@export var magnet_btn: Button
@export var pickaxe_btn: Button
@export var reach_btn: Button
@export var house_btn: Button
@export var tower_btn: Button

# --- CONTROLS ---
@export var close_btn: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	# Connect Close Button
	if close_btn and not close_btn.pressed.is_connected(toggle_shop.bind(false)):
		close_btn.pressed.connect(toggle_shop.bind(false))

	# Connect Upgrade Actions to Variables Autoload
	if gun_btn and not gun_btn.pressed.is_connected(Variables.upgrade_gun):
		gun_btn.pressed.connect(Variables.upgrade_gun)
	if speed_btn and not speed_btn.pressed.is_connected(Variables.upgrade_speed):
		speed_btn.pressed.connect(Variables.upgrade_speed)
	if magnet_btn and not magnet_btn.pressed.is_connected(Variables.upgrade_magnet):
		magnet_btn.pressed.connect(Variables.upgrade_magnet)
	if pickaxe_btn and not pickaxe_btn.pressed.is_connected(Variables.upgrade_pickaxe):
		pickaxe_btn.pressed.connect(Variables.upgrade_pickaxe)
	if reach_btn and not reach_btn.pressed.is_connected(Variables.upgrade_reach):
		reach_btn.pressed.connect(Variables.upgrade_reach)
	if house_btn and not house_btn.pressed.is_connected(Variables.upgrade_house):
		house_btn.pressed.connect(Variables.upgrade_house)
	if tower_btn and not tower_btn.pressed.is_connected(towers.on_tower_purchased):
		tower_btn.pressed.connect(towers.on_tower_purchased)

	# React to Resource & Upgrade Updates
	if Variables.has_signal("resource_updated"):
		Variables.resource_updated.connect(func(_type, _amt): refresh_ui())
	if Variables.has_signal("scrap_updated"):
		Variables.scrap_updated.connect(func(_amt): refresh_ui())
	if Variables.has_signal("upgrades_updated"):
		Variables.upgrades_updated.connect(refresh_ui)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B or event.keycode == KEY_TAB:
			toggle_shop(not visible)

func toggle_shop(open: bool) -> void:
	visible = open
	get_tree().paused = open
	if open:
		refresh_ui()

func refresh_ui() -> void:
	# 1. Update Currencies
	if scrap_label:
		scrap_label.text = "Scrap: %d" % Variables.scrap
	if stone_label:
		stone_label.text = "Stone: %d" % Variables.stone
	if iron_label:
		iron_label.text = "Iron: %d" % Variables.iron

	# 2. Update Scrap-Only Upgrades
	_update_btn_single_cost(gun_btn, "Fire Rate", Variables.gun_level, Variables.get_gun_cost(), "Scrap", Variables.scrap)
	_update_btn_single_cost(speed_btn, "Move Speed", Variables.player_speed_level, Variables.get_speed_cost(), "Scrap", Variables.scrap)
	_update_btn_single_cost(magnet_btn, "Magnet Range", Variables.magnet_level, Variables.get_magnet_cost(), "Scrap", Variables.scrap)

	# 3. Update Stone-Only Upgrades
	_update_btn_single_cost(reach_btn, "Mining Reach", Variables.reach_level, Variables.get_reach_cost(), "Stone", Variables.stone)

	# 4. Update Multi-Resource Upgrades
	_update_btn_dual_cost(
		pickaxe_btn,
		"Pickaxe Damage",
		Variables.pickaxe_level,
		Variables.get_pickaxe_stone_cost(), "Stone", Variables.stone,
		Variables.get_pickaxe_iron_cost(), "Iron", Variables.iron
	)
	
	_update_btn_dual_cost(
		house_btn,
		"Fortify Base",
		Variables.house_reinforce_level,
		Variables.get_house_stone_cost(), "Stone", Variables.stone,
		Variables.get_house_iron_cost(), "Iron", Variables.iron
	)

# Helper: Button with 1 resource cost
func _update_btn_single_cost(btn: Button, item_name: String, level: int, cost: int, res_name: String, current_amt: int) -> void:
	if btn:
		btn.text = "%s (Lv. %d)\nCost: %d %s" % [item_name, level, cost, res_name]
		btn.disabled = (current_amt < cost)

# Helper: Button with 2 resource costs
func _update_btn_dual_cost(btn: Button, item_name: String, level: int, cost1: int, res1_name: String, current_amt1: int, cost2: int, res2_name: String, current_amt2: int) -> void:
	if btn:
		btn.text = "%s (Lv. %d)\n%d %s, %d %s" % [item_name, level, cost1, res1_name, cost2, res2_name]
		btn.disabled = (current_amt1 < cost1 or current_amt2 < cost2)
