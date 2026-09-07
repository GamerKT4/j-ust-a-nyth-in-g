extends Control

signal ready_button_pressed

# UI Nodes
@onready var wave_label: Label = $VBoxContainer/WaveLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var ready_button: Button = $ReadyButton

func _ready() -> void:
	if ready_button and not ready_button.pressed.is_connected(_on_ready_button_pressed):
		ready_button.pressed.connect(_on_ready_button_pressed)
		
	hide_timer()
	hide_ready_button()
	update_wave_text(Variables.current_wave)

# --- TEXT UPDATES ---
func update_wave_text(wave: int) -> void:
	if not wave_label:
		return
		
	wave_label.text = "WAVE %d" % wave
	
	# Punch pop animation on wave announcement
	wave_label.pivot_offset = wave_label.size * 0.5
	var t = create_tween()
	wave_label.scale = Vector2(1.25, 1.25)
	t.tween_property(wave_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func update_timer_text(time_left: float) -> void:
	if time_label:
		time_label.text = "Next wave in: %ds" % int(ceil(time_left))

# --- VISIBILITY ---
func show_timer() -> void:
	if time_label:
		time_label.visible = true

func hide_timer() -> void:
	if time_label:
		time_label.visible = false

func show_ready_button() -> void:
	if ready_button:
		ready_button.visible = true

func hide_ready_button() -> void:
	if ready_button:
		ready_button.visible = false

# --- BUTTON SIGNAL HANDLER ---
func _on_ready_button_pressed() -> void:
	hide_ready_button()
	ready_button_pressed.emit()
