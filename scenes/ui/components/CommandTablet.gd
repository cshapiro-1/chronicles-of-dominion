extends Button
class_name CommandTablet

@export var action_title: String = "SPEARMAN"
@export var hotkey_text: String = "[1]"
@export var cost_text: String = "50g"
@export var button_category: String = "military" # "military", "building", "command"

@onready var lbl_title: Label = get_node_or_null("Margin/VBox/Title")
@onready var lbl_sub: Label = get_node_or_null("Margin/VBox/Sub")

func _ready() -> void:
	custom_minimum_size = Vector2(96, 46)
	_setup_styles()
	update_display()

func _setup_styles() -> void:
	# Normal state: Solid dark slate with crisp border
	var sb_normal = StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.12, 0.15, 0.19, 0.95)
	sb_normal.border_width_left = 1
	sb_normal.border_width_top = 1
	sb_normal.border_width_right = 1
	sb_normal.border_width_bottom = 2
	sb_normal.corner_radius_top_left = 3
	sb_normal.corner_radius_top_right = 3
	sb_normal.corner_radius_bottom_left = 3
	sb_normal.corner_radius_bottom_right = 3
	
	if button_category == "building":
		sb_normal.border_color = Color(0.35, 0.65, 0.85, 0.8) # Blue-cyan border for buildings
	elif button_category == "command":
		sb_normal.border_color = Color(0.85, 0.65, 0.25, 0.8) # Gold border for commands
	else:
		sb_normal.border_color = Color(0.75, 0.45, 0.25, 0.8) # Bronze border for military
		
	# Hover state: Bright highlight
	var sb_hover = sb_normal.duplicate()
	sb_hover.bg_color = Color(0.18, 0.24, 0.32, 0.98)
	sb_hover.border_color = Color(0.4, 0.9, 1.0, 1.0)
	
	# Pressed state
	var sb_pressed = sb_normal.duplicate()
	sb_pressed.bg_color = Color(0.08, 0.10, 0.14, 0.98)
	sb_pressed.border_color = Color(1.0, 0.85, 0.3, 1.0)
	
	add_theme_stylebox_override("normal", sb_normal)
	add_theme_stylebox_override("hover", sb_hover)
	add_theme_stylebox_override("pressed", sb_pressed)
	add_theme_stylebox_override("focus", sb_hover)

func set_action_data(title: String, hotkey: String, cost: String, category: String = "military") -> void:
	action_title = title
	hotkey_text = hotkey
	cost_text = cost
	button_category = category
	_setup_styles()
	update_display()

func update_display() -> void:
	if lbl_title:
		lbl_title.text = action_title.to_upper()
	if lbl_sub:
		if cost_text != "":
			lbl_sub.text = "%s  %s" % [hotkey_text, cost_text]
		else:
			lbl_sub.text = hotkey_text

func _pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.04)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.06)
