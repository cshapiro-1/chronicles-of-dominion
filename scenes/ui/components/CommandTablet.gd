extends TextureButton

@export var hotkey: String = "[1]"

func _ready() -> void:
	pass

func set_icon_texture(tex: Texture2D) -> void:
	if tex:
		texture_normal = tex

func _pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.05)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)
