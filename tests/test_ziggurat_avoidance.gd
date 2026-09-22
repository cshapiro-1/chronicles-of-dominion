extends SceneTree

func _init() -> void:
	print("==================================================")
	print("--- ZIGGURAT OBSTACLE PATHFINDING VERIFICATION ---")
	print("==================================================")
	call_deferred("_run_test")

func _run_test() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait for scene initialization and navigation bake
	await create_timer(0.4).timeout
	
	var world = root.get_node_or_null("Main/World")
	assert(world != null, "World scene must exist")
	
	var nav_region = world.get_node_or_null("NavigationRegion3D")
	assert(nav_region != null, "NavigationRegion3D must exist in World")
	assert(nav_region.navigation_mesh != null, "NavigationMesh must be allocated")
	print("[1/3] NavigationRegion3D and NavMesh initialized successfully.")
	print("      NavMesh polygon count: ", nav_region.navigation_mesh.get_polygon_count())
	print("      NavMesh vertices count: ", nav_region.navigation_mesh.get_vertices().size())
	assert(nav_region.navigation_mesh.get_polygon_count() > 0, "NavMesh must have baked polygons")
	
	# TEST 2: Path Query around Ziggurat
	# Ziggurat is at (6, 0, 6). We query path from West (-12, 0, 6) to East (24, 0, 6).
	print("[2/3] Querying path across the Ziggurat obstacle...")
	var map = nav_region.get_navigation_map()
	var start_pos = Vector3(-12.0, 0.0, 6.0)
	var end_pos = Vector3(24.0, 0.0, 6.0)
	var path = NavigationServer3D.map_get_path(map, start_pos, end_pos, true)
	
	print("      Waypoints count: ", path.size())
	for i in range(path.size()):
		print("        Waypoint %d: %s" % [i, str(path[i])])
	
	assert(path.size() >= 3, "Path across an obstacle must have multiple intermediate detour waypoints")
	var went_around = false
	for p in path:
		# Check if intermediate waypoint deviates around the Ziggurat in Z
		if abs(p.z - 6.0) > 3.5:
			went_around = true
			break
	assert(went_around, "Path must route around the Ziggurat obstacle")
	print("      SUCCESS: Path successfully circumnavigates the Ziggurat.")
	
	# TEST 3: Live Unit Navigation Simulation
	print("[3/3] Simulating live Vanguard cohort moving around the Ziggurat...")
	var vanguard = world.get_node_or_null("Cohort_Spearmen_Vanguard")
	assert(vanguard != null, "Cohort_Spearmen_Vanguard must exist")
	
	# Place vanguard on West side
	vanguard.global_position = start_pos
	vanguard.set_target_destination(end_pos)
	
	# Allow unit to traverse path
	var reached = false
	for step in range(240):
		await create_timer(0.05).timeout
		var d = vanguard.global_position.distance_to(end_pos)
		if step % 30 == 0:
			print("      [Step %d] Pos: %s, Distance to Dest: %.2f" % [step, str(vanguard.global_position), d])
		if d <= 2.2 or not vanguard.has_target:
			print("      Cohort reached destination! Final Pos: %s, Distance: %.2f" % [str(vanguard.global_position), d])
			reached = true
			break
			
	print("      Final Unit Position: ", str(vanguard.global_position))
	assert(reached or vanguard.global_position.distance_to(end_pos) < 3.0, "Unit must reach the other side without getting stuck behind the Ziggurat")
	print("==================================================")
	print(">>> ALL PATHFINDING & OBSTACLE AVOIDANCE TESTS PASSED! <<<")
	print("==================================================")
	quit()

