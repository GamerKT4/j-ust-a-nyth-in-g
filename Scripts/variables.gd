extends Node

# --- SIGNALS ---
signal resource_updated(type: String, new_amount: int)
signal scrap_updated(new_amount: int)
signal upgrades_updated

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

var magnet_level: int = 1
var player_magnet_range: float = 120.0

var house_health: float = 500.0

# --- BUG & WAVE SETTINGS ---
var bug_speed: float = 180.0
var bug_damage: float = 10.0
var bug_health: float = 20.0

var spawn_delay: float = 1.0
var spawn_margin: float = 60.0
var current_wave: int = 1
var bugs_per_wave: int = 5
var wave_break_time: float = 5.0

# --- UPGRADES & COST HELPERS ---
func get_cost(level: int, base: int) -> int:
	return level * base

func get_gun_cost() -> int:
	return get_cost(gun_level, 10)

func get_speed_cost() -> int:
	return get_cost(player_speed_level, 8)

func get_magnet_cost() -> int:
	return get_cost(magnet_level, 6)

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
