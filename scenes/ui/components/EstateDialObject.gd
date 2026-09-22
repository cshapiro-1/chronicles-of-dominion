extends VBoxContainer

@export var title: String = "NOBILITY"
@export_range(0.0, 100.0) var fill_percent: float = 65.0

@onready var dial_bg: TextureRect = $DialFrame/DialBg
@onready var needle: Line2D = $DialFrame/Needle
@onready var lbl_title: Label = $Placard/Margin/HBox/Title
@onready var lbl_pct: Label = $Placard/Margin/HBox/Pct

func _ready() -> void:
	var tex = _load_tex("res://assets/ui/dial_brass_master.png")
	if tex and dial_bg:
		dial_bg.texture = tex
	
	if lbl_title:
		lbl_title.text = title.to_upper()
	set_loyalty(fill_percent)

func _load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	var global_p = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_p):
		var img = Image.load_from_file(global_p)
		if img:
			return ImageTexture.create_from_image(img)
	return null

func set_loyalty(value: float) -> void:
	fill_percent = clamp(value, 0.0, 100.0)
	if lbl_pct:
		lbl_pct.text = "%d%%" % int(fill_percent)
		if fill_percent > 70.0:
			lbl_pct.modulate = Color(0.48, 0.95, 0.52)
		elif fill_percent < 35.0:
			lbl_pct.modulate = Color(1.0, 0.35, 0.35)
		else:
			lbl_pct.modulate = Color(1.0, 0.90, 0.40)
			
	if needle:
		# Angle from -120 deg (0%) to +120 deg (100%)
		var deg = -120.0 + (fill_percent / 100.0) * 240.0
		needle.rotation_degrees = deg
