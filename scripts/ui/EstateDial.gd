extends Control

@export var title: String = "ESTATE"
@export var icon_symbol: String = "🏛"
@export var base_color: Color = Color(0.85, 0.7, 0.25)
@export var fill_percent: float = 65.0

var current_val: float = 65.0

func _process(delta: float) -> void:
	if abs(current_val - fill_percent) > 0.1:
		current_val = lerp(current_val, fill_percent, 8.0 * delta)
		queue_redraw()

func set_percentage(p: float) -> void:
	fill_percent = clamp(p, 0.0, 100.0)

func _draw() -> void:
	var center = size * 0.5
	var radius = min(center.x, center.y) - 4.0
	
	# Background disc
	draw_circle(center, radius, Color(0.08, 0.07, 0.06, 0.95))
	
	# Background track arc
	var start_angle = deg_to_rad(135.0)
	var end_angle = deg_to_rad(405.0)
	draw_arc(center, radius - 4.0, start_angle, end_angle, 48, Color(0.2, 0.18, 0.15, 0.8), 5.0, true)
	
	# Value arc
	var val_angle = start_angle + deg_to_rad(270.0) * (current_val / 100.0)
	var arc_color = base_color
	if current_val < 30.0:
		arc_color = Color(0.9, 0.25, 0.2)
	elif current_val > 70.0:
		arc_color = Color(0.3, 0.85, 0.4)
		
	# Outer border ring
	draw_arc(center, radius, 0.0, TAU, 64, Color(0.65, 0.52, 0.25, 0.9), 2.0, true)
	draw_arc(center, radius - 8.0, 0.0, TAU, 64, Color(0.35, 0.28, 0.15, 0.5), 1.0, true)
	
	# Center needle pointer
	var needle_dir = Vector2.from_angle(val_angle)
	draw_line(center, center + needle_dir * (radius - 5.0), Color(1.0, 0.88, 0.45, 0.95), 2.0)
	draw_circle(center, 3.5, Color(0.85, 0.7, 0.3))
	draw_circle(center, 1.8, Color(0.15, 0.12, 0.08))

