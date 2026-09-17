extends PanelContainer

@export var icon_text: String = "🌾"
@export var default_value: int = 1000
@export var default_delta: int = 25

@onready var lbl_icon: Label = $Margin/HBox/Icon
@onready var lbl_val: Label = $Margin/HBox/VBox/Value
@onready var lbl_delta: Label = $Margin/HBox/VBox/Delta

func _ready() -> void:
	lbl_icon.text = icon_text
	set_amount(default_value, default_delta)

func set_amount(val: int, delta: int = 0) -> void:
	lbl_val.text = _format_num(val)
	if delta > 0:
		lbl_delta.text = "+%d/m" % delta
		lbl_delta.modulate = Color(0.4, 1.0, 0.5)
	elif delta < 0:
		lbl_delta.text = "%d/m" % delta
		lbl_delta.modulate = Color(1.0, 0.4, 0.4)
	else:
		lbl_delta.text = "0/m"
		lbl_delta.modulate = Color(0.7, 0.7, 0.7)

func _format_num(n: int) -> String:
	if n >= 10000:
		return "%.1fk" % (n / 1000.0)
	elif n >= 1000:
		return "%d,%03d" % [n / 1000, n % 1000]
	return str(n)
