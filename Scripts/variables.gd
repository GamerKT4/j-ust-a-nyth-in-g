extends Node

# --- SIGNALS ---
signal resource_updated(type: String, new_amount: int)
signal scrap_updated(new_amount: int)
signal upgrades_updated
signal house_health_updated(current_hp: float, max_hp: float)
signal game_won_triggered

# --- ECONOMY ---
var inventory: Dictionary = {
	"scrap": 0,
	"stone": 0,
	"iron": 0
}

var scrap: int:
	get: return inventory["scrap"]
	set(v):
		inventory["scrap"] = v
		resource_updated.emit("scrap", v)
		scrap_updated.emit(v)

var stone: int:
	get: return inventory["stone"]
	set(v):
		inventory["stone"] = v
		resource_updated.emit("stone", v)

var iron: int:
	get: return inventory["iron"]
	set(v):
		inventory["iron"] = v
		resource_updated.emit("iron", v)

func add_resource(type: String, amount: int = 1) -> void:
	if inventory.has(type):
		inventory[type] += amount
		resource_updated.emit(type, inventory[type])
		if type == "scrap":
			scrap_updated.emit(inventory["scrap"])

func spend_resource(type: String, amount: int) -> bool:
	if inventory.get(type, 0) >= amount:
		inventory[type] -= amount
		resource_updated.emit(type, inventory[type])
		if type == "scrap":
			scrap_updated.emit(inventory["scrap"])
		return true
	return false

# Legacy helper
func add_scrap(amount: int = 1) -> void:
	add_resource("scrap", amount)

# --- PLAYER & BASE STATS ---
var player_speed_level: int = 1
var player_speed: float = 250.0

var gun_level: int = 1
var gun_cooldown: float = 1.0
var gun_ammo_limit: int = 20

var magnet_level: int = 1
var player_magnet_range: float = 120.0

var pickaxe_level: int = 1
var pickaxe_damage: int = 1

var reach_level: int = 1
var mining_reach: float = 140.0

var house_reinforce_level: int = 1
var max_house_health: float = 15000.0
var house_health: float = 15000.0

# --- BUG & WAVE SETTINGS ---
var bug_speed: float = 180.0
var bug_damage: float = 10.0
var bug_health: float = 20.0

var spawn_delay: float = 1.0
var spawn_margin: float = 60.0
var current_wave: int = 1
# Check Of Waves For End
var max_waves: int = 5
var bugs_per_wave: int = 5
var wave_break_time: float = 5.0

var is_game_won: bool = false
var is_game_over: bool = false

# --- COST HELPERS ---
func get_gun_cost() -> int:
	return gun_level * 10

func get_speed_cost() -> int:
	return player_speed_level * 8

func get_magnet_cost() -> int:
	return magnet_level * 6

func get_pickaxe_stone_cost() -> int:
	return 8 + (pickaxe_level * 5)

func get_pickaxe_iron_cost() -> int:
	return 2 + (pickaxe_level * 2)

func get_reach_cost() -> int:
	return 6 + (reach_level * 4)

func get_house_iron_cost() -> int:
	return 4 + (house_reinforce_level * 3)

func get_house_stone_cost() -> int:
	return 10 + (house_reinforce_level * 4)

# --- UPGRADE ACTIONS ---
func upgrade_gun() -> void:
	if spend_resource("scrap", get_gun_cost()):
		gun_level += 1
		gun_cooldown = maxf(0.2, 1.0 - ((gun_level - 1) * 0.15))
		upgrades_updated.emit()

func upgrade_speed() -> void:
	if spend_resource("scrap", get_speed_cost()):
		player_speed_level += 1
		player_speed += 25.0
		upgrades_updated.emit()

func upgrade_magnet() -> void:
	if spend_resource("scrap", get_magnet_cost()):
		magnet_level += 1
		player_magnet_range += 40.0
		upgrades_updated.emit()

func upgrade_pickaxe() -> void:
	var cost_stone = get_pickaxe_stone_cost()
	var cost_iron = get_pickaxe_iron_cost()
	if inventory.get("stone", 0) >= cost_stone and inventory.get("iron", 0) >= cost_iron:
		spend_resource("stone", cost_stone)
		spend_resource("iron", cost_iron)
		pickaxe_level += 1
		pickaxe_damage += 1
		upgrades_updated.emit()

func upgrade_reach() -> void:
	var cost_stone = get_reach_cost()
	if spend_resource("stone", cost_stone):
		reach_level += 1
		mining_reach += 30.0
		upgrades_updated.emit()

func upgrade_house() -> void:
	var cost_iron = get_house_iron_cost()
	var cost_stone = get_house_stone_cost()
	if inventory.get("iron", 0) >= cost_iron and inventory.get("stone", 0) >= cost_stone:
		spend_resource("iron", cost_iron)
		spend_resource("stone", cost_stone)
		house_reinforce_level += 1
		max_house_health += 25.0
		house_health += 25.0
		house_health_updated.emit(house_health, max_house_health)
		upgrades_updated.emit()

# --- WIN & VICTORY LOGIC ---
func trigger_victory() -> void:
	if is_game_over or is_game_won:
		return
	is_game_won = true
	game_won_triggered.emit()

# --- RUN RESET ---
func reset_game() -> void:
	scrap = 0
	stone = 0
	iron = 0

	current_wave = 1
	bugs_per_wave = 5
	spawn_delay = 1.0
	wave_break_time = 5.0
	
	max_house_health = 100.0
	house_health = 100.0

	bug_speed = 180.0
	bug_damage = 10.0
	bug_health = 20.0

	player_speed_level = 1
	player_speed = 250.0

	gun_level = 1
	gun_cooldown = 1.0

	magnet_level = 1
	player_magnet_range = 120.0

	pickaxe_level = 1
	pickaxe_damage = 1

	reach_level = 1
	mining_reach = 140.0

	house_reinforce_level = 1
	is_game_won = false
	is_game_over = false

	upgrades_updated.emit()
