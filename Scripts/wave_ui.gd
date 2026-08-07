extends Control

# UI Nodes
@onready var polygon: Polygon2D = $Polygon2D
@onready var vbox: VBoxContainer = $VBoxContainer
@onready var wave_label: Label = $VBoxContainer/WaveLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel

# Trapezium banner dimensions (in pixels)
@export var top_width: float = 200.0
@export var bottom_width: float = 140.0
@export var banner_height: float = 60.0

func _ready() -> void:
	# 1. Listen for whenever the game window changes size
	get_viewport().size_changed.connect(update_layout)
	
	# 2. Run the math immediately when the game starts
	update_layout()
	update_wave_text(Variables.current_wave)

# --- THE MATH & RESIZING ENGINE ---
func update_layout() -> void:
	# Find the exact horizontal center of the screen
	var screen_width = get_viewport().size.x
	var center_x = screen_width / 2.0
	
	# Calculate half-widths to push points left and right from center
	var half_top = top_width / 2.0
	var half_bottom = bottom_width / 2.0
	
	# Calculate the 4 corners of the trapezium (X, Y)
	var top_left     = Vector2(center_x - half_top, 0)
	var top_right    = Vector2(center_x + half_top, 0)
	var bottom_right = Vector2(center_x + half_bottom, banner_height)
	var bottom_left  = Vector2(center_x - half_bottom, banner_height)
	
	# Apply the new calculated points to redraw the shape
	if polygon:
		polygon.polygon = PackedVector2Array([top_left, top_right, bottom_right, bottom_left])
	
	# Center the text box inside the new shape coordinates
	if vbox:
		vbox.size = Vector2(bottom_width, banner_height)
		vbox.position = Vector2(center_x - half_bottom, 5.0)

# --- TEXT UPDATES ---
func update_wave_text(wave_number: int) -> void:
	if wave_label:
		wave_label.text = "WAVE: " + str(wave_number)

func update_timer_text(time_left: float) -> void:
	if time_label:
		time_label.text = str(int(ceil(time_left))) + "s"

func show_timer(is_visible: bool) -> void:
	if time_label:
		time_label.visible = is_visible
