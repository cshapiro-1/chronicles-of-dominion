extends StaticBody3D

@onready var house_mesh: MeshInstance3D = $Mesh

func _ready() -> void:
	if house_mesh:
		house_mesh.mesh = MeshFactory.create_house_mesh()
