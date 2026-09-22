extends SceneTree

func _init() -> void:
	var f = FileAccess.open("C:/Users/Collin/Documents/GodotProjects/ChroniclesOfDominion/test_output.txt", FileAccess.WRITE)
	f.store_line("=== TESTING NAVIGATION BAKE & PATHFINDING ===")
	
	var nav_region = NavigationRegion3D.new()
	var nav_mesh = NavigationMesh.new()
	nav_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_BOTH
	nav_mesh.agent_radius = 1.4
	nav_mesh.agent_height = 2.0
	nav_mesh.agent_max_climb = 0.5
	nav_mesh.agent_max_slope = 45.0
	nav_mesh.cell_size = 0.4
	nav_mesh.cell_height = 0.2
	nav_region.navigation_mesh = nav_mesh
	root.add_child(nav_region)
	
	# Ground
	var ground = StaticBody3D.new()
	var ground_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(200, 200)
	ground_mesh.mesh = plane
	ground.add_child(ground_mesh)
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(200, 1, 200)
	col.shape = box
	col.position = Vector3(0, -0.5, 0)
	ground.add_child(col)
	nav_region.add_child(ground)
	
	# Ziggurat static body at (6, 0, 6) with size 22 x 10 x 22
	var zig = StaticBody3D.new()
	zig.position = Vector3(6, 0, 6)
	var zig_col = CollisionShape3D.new()
	var zig_box = BoxShape3D.new()
	zig_box.size = Vector3(22, 10, 22)
	zig_col.shape = zig_box
	zig_col.position = Vector3(0, 5, 0)
	zig.add_child(zig_col)
	nav_region.add_child(zig)
	
	# Parse and bake
	var source_data = NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(nav_mesh, source_data, nav_region)
	NavigationServer3D.bake_from_source_geometry_data(nav_mesh, source_data)
	nav_region.navigation_mesh = nav_mesh
	
	f.store_line("Bake complete. Polygons count: " + str(nav_mesh.get_polygon_count()))
	f.store_line("Vertices count: " + str(nav_mesh.get_vertices().size()))
	
	# Setup map
	var map = nav_region.get_navigation_map()
	NavigationServer3D.region_set_map(nav_region.get_region_rid(), map)
	NavigationServer3D.region_set_navigation_mesh(nav_region.get_region_rid(), nav_mesh)
	
	# Sync server
	NavigationServer3D.sync()
	
	# Test path from (-12, 0, 6) to (24, 0, 6)
	var start_p = Vector3(-12, 0, 6)
	var end_p = Vector3(24, 0, 6)
	var path = NavigationServer3D.map_get_path(map, start_p, end_p, true)
	
	f.store_line("Computed path length: " + str(path.size()))
	for i in range(path.size()):
		f.store_line("  Waypoint %d: %s" % [i, str(path[i])])
		
	var went_around = false
	for p in path:
		if abs(p.z - 6.0) > 4.0:
			went_around = true
			break
	f.store_line("Went around obstacle: " + str(went_around))
	f.close()
	quit()
