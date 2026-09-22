extends Node3D

@onready var palm_mesh: MeshInstance3D = get_node_or_null("TrunkMesh")

func _ready() -> void:
	if palm_mesh:
		palm_mesh.mesh = MeshFactory.create_palm_mesh()
