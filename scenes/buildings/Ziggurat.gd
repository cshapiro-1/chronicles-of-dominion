extends StaticBody3D

@onready var monument_mesh: MeshInstance3D = $MonumentMesh

func _ready() -> void:
	if monument_mesh:
		monument_mesh.mesh = MeshFactory.create_ziggurat_mesh()

func recruit_unit(unit_name: String) -> void:
	var units_node = get_tree().root.get_node_or_null("Main/World/Units")
	if not units_node:
		return
	
	var unit_scene = preload("res://scenes/units/Unit.tscn")
	var new_unit = unit_scene.instantiate()
	var res_path = "res://data/units/" + unit_name + ".tres"
	if ResourceLoader.exists(res_path):
		new_unit.unit_data = load(res_path)
	
	new_unit.global_position = global_position + Vector3(randf_range(-5.0, 5.0), 0.0, 24.0)
	units_node.add_child(new_unit)
	EventBus.post_notification("LEGION MUSTERED", "%s Cohort ready at the Ziggurat gate." % unit_name, Color(0.4, 0.9, 0.5))
