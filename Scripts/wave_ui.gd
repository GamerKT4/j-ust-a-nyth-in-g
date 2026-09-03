extends Control

signal ready_button_pressed

# UI Nodes
@onready var wave_label: Label = $VBoxContainer/WaveLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var ready_button: Button = $ReadyButton
@onready var scrap_label: Label = $ScrapLabel

func _ready() -> void:
	if ready_button and not ready_button.pressed.is_connected(_on_ready_button_pressed):
		ready_button.pressed.connect(_on_ready_button_pressed)
		
	hide_timer()
	hide_ready_button()
	update_wave_text(Variables.current_wave)
	
	update_scrap_text(Variables.scrap)
	Variables.scrap_updated.connect(update_scrap_text)

# --- TEXT UPDATES ---
func update_wave_text(wave: int) -> void:
	if wave_label:
		wave_label.text = "WAVE " + str(wave)

func update_timer_text(time_left: float) -> void:
	if time_label:
		time_label.text = "Next wave in: " + str(int(ceil(time_left))) + "s"

func update_scrap_text(amount: int) -> void:
	if scrap_label:
		scrap_label.text = "SCRAP: " + str(amount)

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
