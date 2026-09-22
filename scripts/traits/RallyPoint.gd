class_name TraitRallyPoint
extends Node3D

@export var rally_destination: Vector3 = Vector3.ZERO
var flag_mesh: MeshInstance3D = null

func _ready() -> void:
	rally_destination = global_position + Vector3(0, 0, 5.0)
	_create_flag()

func _create_flag() -> void:
	flag_mesh = MeshInstance3D.new()
	var pole = CylinderMesh.new()
	pole.top_radius = 0.05
	pole.bottom_radius = 0.05
	pole.height = 2.4
	flag_mesh.mesh = pole
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.85, 0.35)
	flag_mesh.material_override = mat
	flag_mesh.position = rally_destination
	flag_mesh.visible = false
	add_child(flag_mesh)

func set_rally_point(pos: Vector3) -> void:
	rally_destination = pos
	if flag_mesh:
		flag_mesh.global_position = pos
