extends Control

@onready var label: Label = $Temp
@onready var bug_speed_slider: HSlider = $BugSpeedSlider

@onready var labels: Dictionary = {
	"scrap": $ResourceBar/ScrapLabel,
	"stone": $ResourceBar/StoneLabel,
	"iron":  $ResourceBar/IronLabel
}

func _ready() -> void:
	# Center the pivot so the pulse scales outward evenly from the center
	for lbl: Label in labels.values():
		lbl.pivot_offset = lbl.size * 0.5

	if Variables.has_signal("resource_updated"):
		Variables.resource_updated.connect(_on_resource_updated)

	# Initialize all values without triggering animations on boot
	for type in labels.keys():
		labels[type].text = "%s: %d" % [type.capitalize(), Variables.inventory.get(type, 0)]
	
	label.text = str(bug_speed_slider.value)

func _on_resource_updated(type: String, new_amount: int) -> void:
	if not labels.has(type):
		return
	
	var lbl: Label = labels[type]
	lbl.text = "%s: %d" % [type.capitalize(), new_amount]
	_pop_label(lbl)

func _pop_label(lbl: Label) -> void:
	# Kill any existing tween on this label so rapid pickups don't desync
	var t = create_tween()
	lbl.scale = Vector2(1.22, 1.22)
	t.tween_property(lbl, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_bug_speed_slider_value_changed(value: float) -> void:
	label.text = str(value)
