extends Node

# Economy & Currency
var scrap: int = 0
signal scrap_updated(new_amount: int)

# Player & House
var player_speed: float = 250.0
var house_health: float = 500.0

# Bug Settings
var bug_speed: float = 180.0
var bug_damage: float = 10.0
var bug_health: float = 20.0

# Bug Spawning
var spawn_delay: float = 1.0 
var spawn_margin: float = 60.0 

# Wave System
var current_wave: int = 1
var bugs_per_wave: int = 5
var wave_break_time: float = 5.0

func add_scrap(amount: int) -> void:
	scrap += amount
	scrap_updated.emit(scrap)

func spend_scrap(amount: int) -> bool:
	if scrap >= amount:
		scrap -= amount
		scrap_updated.emit(scrap)
		return true
	return false
