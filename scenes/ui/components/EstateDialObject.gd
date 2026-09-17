extends VBoxContainer

@export var title: String = "ALTAR"
@export var fill_percent: float = 60.0

@onready var needle: Line2D = $DialFrame/Needle
@onready var lbl_title: Label = $Placard/Margin/HBox/Title
@onready var lbl_pct: Label = $Placard/Margin/HBox/Pct

var current_val: float = 60.0
var target_val: float = 60.0

func _ready() -> void:
	lbl_title.text = title
	set_percentage(fill_percent)

func _process(delta: float) -> void:
	current_val = lerp(current_val, target_val, 10.0 * delta)
	# Map 0..100% to -120 deg to +120 deg
	var angle_deg = lerp(-120.0, 120.0, current_val / 100.0)
	needle.rotation_degrees = angle_deg
	lbl_pct.text = "%d%%" % int(current_val)
	
	if current_val < 35.0:
		lbl_pct.modulate = Color(1.0, 0.3, 0.3)
	elif current_val < 50.0:
		lbl_pct.modulate = Color(1.0, 0.8, 0.3)
	else:
		lbl_pct.modulate = Color(0.4, 1.0, 0.5)

func set_percentage(pct: float) -> void:
	target_val = clamp(pct, 0.0, 100.0)
