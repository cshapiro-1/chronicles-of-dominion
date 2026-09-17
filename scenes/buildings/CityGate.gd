extends StaticBody3D

@onready var gate_mesh: MeshInstance3D = $GateMesh

func _ready() -> void:
	if gate_mesh:
		gate_mesh.mesh = MeshFactory.create_city_gate_mesh()
