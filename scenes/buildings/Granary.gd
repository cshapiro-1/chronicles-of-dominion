extends StaticBody3D

@onready var gran_mesh: MeshInstance3D = $Mesh

func _ready() -> void:
	if gran_mesh:
		gran_mesh.mesh = MeshFactory.create_granary_mesh()
