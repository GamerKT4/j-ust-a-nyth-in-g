extends Node

# Economy & Currency
var scrap: int = 0
signal scrap_updated(new_amount: int)

# Upgrades & Scaling
var gun_level: int = 1
var player_speed_level: int = 1
var magnet_level: int = 1
signal upgrades_updated

# Player & House Stats
var player_speed: float = 250.0
var player_magnet_range: float = 120.0
var house_health: float = 500.0

# Gun Stats
var gun_cooldown: float = 1.0

# Bug Settings
var bug_speed: float = 180.0
var bug_damage: float = 10.0
var bug_health: float = 20.0

# Spawning & Waves
var spawn_delay: float = 1.0 
var spawn_margin: float = 60.0 
var current_wave: int = 1
var bugs_per_wave: int = 5
var wave_break_time: float = 5.0

# --- ECONOMY FUNCTIONS ---
func add_scrap(amount: int) -> void:
	scrap += amount
	scrap_updated.emit(scrap)

func spend_scrap(amount: int) -> bool:
	if scrap >= amount:
		scrap -= amount
		scrap_updated.emit(scrap)
		return true
	return false

# --- UPGRADE LOGIC ---
func get_gun_cost() -> int:
	return gun_level * 10

func get_speed_cost() -> int:
	return player_speed_level * 8

func get_magnet_cost() -> int:
	return magnet_level * 6

func upgrade_gun() -> void:
	if spend_scrap(get_gun_cost()):
		gun_level += 1
		gun_cooldown = max(0.2, 1.0 - ((gun_level - 1) * 0.15))
		upgrades_updated.emit()

func upgrade_speed() -> void:
	if spend_scrap(get_speed_cost()):
		player_speed_level += 1
		player_speed += 25.0
		upgrades_updated.emit()

func upgrade_magnet() -> void:
	if spend_scrap(get_magnet_cost()):
		magnet_level += 1
		player_magnet_range += 40.0
		upgrades_updated.emit()
