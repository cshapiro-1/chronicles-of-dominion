extends SceneTree

func _init() -> void:
	print("==================================================")
	print("--- MULTI-UNIT MASS PATHFINDING TEST ---")
	print("==================================================")
	call_deferred("_run_test")

func _run_test() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait for scene initialization and NavMesh bake
	await create_timer(0.4).timeout
	
	var world = root.get_node_or_null("Main/World")
	var hud = root.get_node_or_null("Main/UI/HUD")
	var unit_scene = load("res://scenes/units/Unit.tscn")
	
	# Clean up any existing units to have a clean test formation
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u):
			u.queue_free()
			
	await create_timer(0.1).timeout
	
	print("[1/3] Spawning 10-unit Imperial Host on West Flank...")
	var test_units = []
	var west_start = Vector3(-16.0, 0.0, 6.0)
	for i in range(10):
		var u = unit_scene.instantiate()
		var unit_types = ["spearman", "spearman", "slinger", "spearman", "chariot", "spearman", "slinger", "spearman", "chariot", "spearman"]
		u.unit_type = unit_types[i]
		u.team_id = 0
		var r = i / 3
		var c = i % 3
		u.position = west_start + Vector3((c - 1.0) * 3.5, 0.0, (r - 1.5) * 3.5)
		world.add_child(u)
		test_units.append(u)
		
	await create_timer(0.2).timeout
	print("      Spawned %d units. Selecting all..." % test_units.size())
	hud._select_units(test_units)
	
	# Issue mass movement order to East side across the Ziggurat
	var east_target = Vector3(28.0, 0.0, 6.0)
	print("[2/3] Issuing mass formation move command across Ziggurat to: ", str(east_target))
	var count = test_units.size()
	for i in range(count):
		var u = test_units[i]
		var offset = hud._compute_formation_offset(i, count)
		u.set_target_destination(east_target + offset)
		
	# Monitor army travel over 280 physics steps (~14 seconds)
	print("[3/3] Tracking cohort movement around Ziggurat...")
	for step in range(280):
		await create_timer(0.05).timeout
		if step % 40 == 0:
			var arrived_count = 0
			for u in test_units:
				if is_instance_valid(u) and u.global_position.x > 18.0:
					arrived_count += 1
			print("      [Step %d] %d / %d units have crossed the Ziggurat to East flank" % [step, arrived_count, count])
			
	var fully_reached = 0
	for i in range(count):
		var u = test_units[i]
		var d = u.global_position.distance_to(u.target_destination)
		var passed = u.global_position.x > 15.0 or d < 3.5
		if passed:
			fully_reached += 1
		print("      Unit %d (%s): Final Pos = %s, Target = %s, Dist = %.2f [Passed: %s]" % [
			i, u.unit_type, str(u.global_position), str(u.target_destination), d, str(passed)
		])
		
	print("==================================================")
	print("Result: %d / %d units successfully navigated around the Ziggurat!" % [fully_reached, count])
	assert(fully_reached >= 9, "At least 90%+ of the massed units must successfully circumnavigate the Ziggurat without getting stuck")
	print(">>> MASS TROOP PATHFINDING TEST PASSED! <<<")
	print("==================================================")
	quit()
