class_name TraitSelection
extends Node3D

@export var selection_radius: float = 1.2
@export var is_selected: bool = false:
	set(val):
		is_selected = val
		_update_visuals()

var ring_mesh: MeshInstance3D = null

func _ready() -> void:
	_create_ring()
	_update_visuals()

func _create_ring() -> void:
	ring_mesh = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = selection_radius - 0.08
	torus.outer_radius = selection_radius
	ring_mesh.mesh = torus
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.95, 0.82, 0.35, 0.95) # Gold ring
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mesh.material_override = mat
	ring_mesh.position.y = 0.08
	add_child(ring_mesh)

func _update_visuals() -> void:
	if ring_mesh:
		ring_mesh.visible = is_selected
