extends StaticBody3D

@onready var soil_bed: MeshInstance3D = $SoilBed

func _ready() -> void:
	if soil_bed:
		soil_bed.mesh = MeshFactory.create_farm_mesh()
