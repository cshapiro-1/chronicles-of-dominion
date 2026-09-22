class_name TraitHealthBar
extends Node3D

@export var max_health: float = 100.0
@export var current_health: float = 100.0:
	set(val):
		current_health = clamp(val, 0.0, max_health)
		_update_bar()

@export var bar_width: float = 1.4
@export var bar_height: float = 0.14
@export var bar_offset_y: float = 2.4

var bg_quad: MeshInstance3D = null
var fg_quad: MeshInstance3D = null
var mat_fg: StandardMaterial3D = null

func _ready() -> void:
	_build_bar()
	_update_bar()

func _build_bar() -> void:
	# Background (Dark Bronze/Slate)
	bg_quad = MeshInstance3D.new()
	var q_bg = QuadMesh.new()
	q_bg.size = Vector2(bar_width, bar_height)
	bg_quad.mesh = q_bg
	var mat_bg = StandardMaterial3D.new()
	mat_bg.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_bg.albedo_color = Color(0.12, 0.10, 0.08, 0.85)
	mat_bg.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	bg_quad.material_override = mat_bg
	bg_quad.position.y = bar_offset_y
	add_child(bg_quad)

	# Foreground (Green -> Red gradient based on HP)
	fg_quad = MeshInstance3D.new()
	var q_fg = QuadMesh.new()
	q_fg.size = Vector2(bar_width, bar_height * 0.8)
	fg_quad.mesh = q_fg
	mat_fg = StandardMaterial3D.new()
	mat_fg.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_fg.albedo_color = Color(0.35, 0.90, 0.45)
	mat_fg.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	fg_quad.material_override = mat_fg
	fg_quad.position.y = bar_offset_y
	fg_quad.position.z = 0.01
	add_child(fg_quad)

func _update_bar() -> void:
	if not fg_quad or not mat_fg:
		return
	var pct = current_health / max(max_health, 1.0)
	fg_quad.scale.x = pct
	fg_quad.position.x = -(bar_width * (1.0 - pct) * 0.5)
	
	if pct > 0.6:
		mat_fg.albedo_color = Color(0.35, 0.90, 0.45)
	elif pct > 0.25:
		mat_fg.albedo_color = Color(0.95, 0.80, 0.25)
	else:
		mat_fg.albedo_color = Color(0.95, 0.25, 0.25)
		
	# Hide health bar if full HP to reduce visual clutter
	visible = (pct < 0.99)
