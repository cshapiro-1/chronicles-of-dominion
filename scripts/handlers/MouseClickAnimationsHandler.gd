class_name MouseClickAnimationsHandler
extends Node3D

func spawn_order_ring(world_pos: Vector3, order_type: int) -> void:
	var ring = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.4
	torus.outer_radius = 0.6
	ring.mesh = torus
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	match order_type:
		0: mat.albedo_color = Color(0.35, 0.95, 0.45, 0.9) # Green Move
		1: mat.albedo_color = Color(1.0, 0.25, 0.25, 0.9)  # Red Attack
		2: mat.albedo_color = Color(0.95, 0.85, 0.25, 0.9) # Gold Gather
		3: mat.albedo_color = Color(0.3, 0.7, 1.0, 0.9)    # Blue Build
		_: mat.albedo_color = Color(1.0, 1.0, 1.0, 0.9)
		
	ring.material_override = mat
	ring.position = world_pos + Vector3(0, 0.1, 0)
	add_child(ring)
	
	var tween = create_tween()
	tween.tween_property(ring, "scale", Vector3(1.8, 1.8, 1.8), 0.35)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.35)
	tween.tween_callback(ring.queue_free)
