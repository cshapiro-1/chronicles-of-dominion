extends Node3D

@onready var fire_light: OmniLight3D = $OmniLight3D
@onready var fire_mesh: MeshInstance3D = $FireMesh

var noise_offset: float = 0.0
var base_energy: float = 2.4

func _ready() -> void:
	noise_offset = randf() * 100.0

func _process(delta: float) -> void:
	noise_offset += delta * 12.0
	var flicker = sin(noise_offset) * 0.3 + sin(noise_offset * 2.3) * 0.15
	if fire_light:
		fire_light.light_energy = base_energy + flicker
	if fire_mesh:
		fire_mesh.scale = Vector3.ONE * (1.0 + flicker * 0.12)
