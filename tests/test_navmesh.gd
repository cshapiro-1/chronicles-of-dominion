extends SceneTree

func _init() -> void:
	print("--- Testing Godot 4.3 NavigationRegion3D & Pathfinding ---")
	var root = Node3D.new()
	
	# Create NavigationRegion3D
	var nav_region = NavigationRegion3D.new()
	var nav_mesh = NavigationMesh.new()
	nav_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_BOTH
	nav_mesh.agent_radius = 1.2
	nav_mesh.agent_height = 2.0
	nav_mesh.cell_size = 0.5
	nav_mesh.cell_height = 0.25
	nav_region.navigation_mesh = nav_mesh
	root.add_child(nav_region)
	
	# Ground plane mesh & collider
	var ground = StaticBody3D.new()
	var ground_mesh = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(200, 200)
	ground_mesh.mesh = plane_mesh
	ground.add_child(ground_mesh)
	
	var ground_col = CollisionShape3D.new()
	var ground_box = BoxShape3D.new()
	ground_box.size = Vector3(200, 1, 200)
	ground_col.shape = ground_box
	ground_col.position = Vector3(0, -0.5, 0)
	ground.add_child(ground_col)
	nav_region.add_child(ground)
	
	# Ziggurat obstacle static body at (0, 0, 0)
	var ziggurat = StaticBody3D.new()
	ziggurat.position = Vector3(0, 0, 0)
	var zig_col = CollisionShape3D.new()
	var zig_box = BoxShape3D.new()
	zig_box.size = Vector3(20, 10, 20)
	zig_col.shape = zig_box
	zig_col.position = Vector3(0, 5, 0)
	ziggurat.add_child(zig_col)
	nav_region.add_child(ziggurat)
	
	# Bake navigation mesh
	print("Baking nav mesh...")
	var source_data = NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(nav_mesh, source_data, nav_region)
	NavigationServer3D.bake_from_source_geometry_data(nav_mesh, source_data)
	nav_region.navigation_mesh = nav_mesh
	
	print("Nav mesh polygon count: ", nav_mesh.get_polygon_count())
	print("Nav mesh vertices count: ", nav_mesh.get_vertices().size())
	
	var map = nav_region.get_navigation_map()
	NavigationServer3D.region_set_map(nav_region.get_region_rid(), map)
	NavigationServer3D.region_set_navigation_mesh(nav_region.get_region_rid(), nav_mesh)
	
	# Query path
	var start_pos = Vector3(-20, 0, 0)
	var end_pos = Vector3(20, 0, 0)
	var path = NavigationServer3D.map_get_path(map, start_pos, end_pos, true)
	print("Computed Path Points count: ", path.size())
	for p in path:
		print("  Point: ", p)
	
	quit()
