extends CanvasLayer

@export var balance_label: Label
@export var gun_btn: Button
@export var speed_btn: Button
@export var magnet_btn: Button
@export var close_btn: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if close_btn:
		close_btn.pressed.connect(toggle_shop.bind(false))
	if gun_btn:
		gun_btn.pressed.connect(Variables.upgrade_gun)
	if speed_btn:
		speed_btn.pressed.connect(Variables.upgrade_speed)
	if magnet_btn:
		magnet_btn.pressed.connect(Variables.upgrade_magnet)
	
	Variables.scrap_updated.connect(func(_amt): refresh_ui())
	if Variables.has_signal("upgrades_updated"):
		Variables.upgrades_updated.connect(refresh_ui)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			toggle_shop(not visible)

func toggle_shop(open: bool) -> void:
	visible = open
	get_tree().paused = open
	if open:
		refresh_ui()

func refresh_ui() -> void:
	if balance_label:
		balance_label.text = "SCRAP: " + str(Variables.scrap)
	
	_update_btn(gun_btn, "Fire Rate", Variables.gun_level, Variables.get_gun_cost())
	_update_btn(speed_btn, "Move Speed", Variables.player_speed_level, Variables.get_speed_cost())
	_update_btn(magnet_btn, "Scrap Magnet", Variables.magnet_level, Variables.get_magnet_cost())

func _update_btn(btn: Button, item_name: String, level: int, cost: int) -> void:
	if btn:
		btn.text = item_name + " (Lv. " + str(level) + ") - " + str(cost) + " Scrap"
		btn.disabled = (Variables.scrap < cost)
