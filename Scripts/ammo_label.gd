extends Label

@onready var gun: Node2D = $"../Gun"


func _ready() -> void:
	gun.ammo_changed.connect(update_display)
	gun.reload_started.connect(func(): text = "Reloading...")
	gun.reload_finished.connect(update_display)
	
	update_display()


func update_display() -> void:
	text = "%d / %d" % [gun.ammo, gun.ammo_limit]
