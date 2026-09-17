extends PanelContainer

signal pressed()

@export var hotkey: String = "[1]"
@export var cost_text: String = "🌾50 ⚔20"
@export var tablet_icon: Texture2D

@onready var btn: TextureButton = $Margin/VBox/Btn
@onready var lbl_hotkey: Label = $Margin/VBox/Btn/HotkeyBadge
@onready var lbl_cost: Label = $Margin/VBox/CostLabel

func _ready() -> void:
	lbl_hotkey.text = hotkey
	lbl_cost.text = cost_text
	if tablet_icon:
		btn.texture_normal = tablet_icon

func _on_btn_pressed() -> void:
	pressed.emit()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.06)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)
