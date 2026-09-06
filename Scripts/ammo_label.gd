extends Label

@onready var gun: Node2D = $"../Gun"

func _ready() -> void:
	gun.ammo_changed.connect(_on_ammo_changed)

func _on_ammo_changed():
	self.text = str(gun.ammo) + " / " + str(gun.ammo_limit)
