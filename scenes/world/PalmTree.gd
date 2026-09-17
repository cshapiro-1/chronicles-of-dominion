extends StaticBody3D

@onready var palm_mesh: MeshInstance3D = $Mesh

func _ready() -> void:
	if palm_mesh:
		palm_mesh.mesh = MeshFactory.create_palm_mesh()
