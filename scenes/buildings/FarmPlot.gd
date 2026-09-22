extends StaticBody3D

@onready var farm_mesh: MeshInstance3D = get_node_or_null("SoilBed")

func _ready() -> void:
	if farm_mesh:
		farm_mesh.mesh = MeshFactory.create_farm_mesh()
