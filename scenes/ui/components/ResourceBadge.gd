extends HBoxContainer

@export var resource_name: String = "grain"
@export var default_value: int = 1420
@export var default_delta: int = 45

@onready var icon_rect: TextureRect = $IconRect
@onready var lbl_value: Label = $VBox/Value
@onready var lbl_delta: Label = $VBox/Delta

func _ready() -> void:
	_load_icon()
	set_amount(default_value, default_delta)

func _load_icon() -> void:
	var path = "res://assets/ui/icon_res_%s.png" % resource_name.to_lower()
	var global_p = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_p):
		var img = Image.load_from_file(global_p)
		if img:
			icon_rect.texture = ImageTexture.create_from_image(img)
			return
	if ResourceLoader.exists(path):
		icon_rect.texture = load(path)

func set_amount(amount: int, delta: int) -> void:
	if lbl_value:
		lbl_value.text = _format_number(amount)
	if lbl_delta:
		if resource_name.to_lower() == "pop":
			lbl_delta.text = "100%"
			lbl_delta.modulate = Color(0.42, 0.72, 0.70, 1)
		elif delta > 0:
			lbl_delta.text = "(+%s/m)" % _format_number(delta)
			lbl_delta.modulate = Color(0.42, 0.72, 0.70, 1)
		elif delta < 0:
			lbl_delta.text = "(%s/m)" % _format_number(delta)
			lbl_delta.modulate = Color(0.95, 0.40, 0.40, 1)
		else:
			lbl_delta.text = "(+0/m)"
			lbl_delta.modulate = Color(0.60, 0.65, 0.65, 1)

func _format_number(n: int) -> String:
	return str(n)

