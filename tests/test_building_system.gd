extends SceneTree

const Building = preload("res://scenes/buildings/Building.gd")

func _init() -> void:
	print("==================================================")
	print("--- BUILDING & STRUCTURE SUBSYSTEM TEST ---")
	print("==================================================")
	call_deferred("_run_test")

func _run_test() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait for scene initialization and baseline NavMesh bake
	await create_timer(0.4).timeout
	
	var world = root.get_node_or_null("Main/World")
	var hud = root.get_node_or_null("Main/UI/HUD")
	var eco_mgr = root.get_node_or_null("/root/EconomyManager")
	var pop_mgr = root.get_node_or_null("/root/PopulationManager")
	var placement_handler = hud.placement_handler if hud else null
	
	assert(world != null, "World node must exist in Main scene")
	assert(hud != null, "HUD node must exist in Main scene")
	assert(eco_mgr != null, "EconomyManager must exist")
	assert(pop_mgr != null, "PopulationManager must exist")
	assert(placement_handler != null, "StructurePlacementHandler must exist in HUD")
	
	# Clear out test units for clean test environment
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u):
			u.queue_free()
			
	await create_timer(0.1).timeout
	
	# Reset resources for testing
	eco_mgr.resources["Gold"] = 2000
	eco_mgr.resources["Wood"] = 1000
	eco_mgr.resources["Mudbrick"] = 1000
	eco_mgr.resources["Grain"] = 1000
	pop_mgr.conscription_pool = 50
	
	var initial_gold = eco_mgr.resources["Gold"]
	var initial_grain_delta = eco_mgr.deltas.get("Grain", 0.0)
	var initial_gold_delta = eco_mgr.deltas.get("Gold", 0.0)
	var initial_housing = pop_mgr.max_housing
	
	# -------------------------------------------------------------
	# STEP 1: Test Placement & Resource Costs (Granary & Tenement)
	# -------------------------------------------------------------
	print("\n[TEST 1/6] Testing Structure Placement & Cost Deduction...")
	
	placement_handler.start_placement("granary")
	assert(placement_handler.is_placing, "Placement handler should be in placing state")
	placement_handler.update_ghost_position(Vector3(15.0, 0.0, -10.0))
	assert(placement_handler.is_valid_location, "Location (15, 0, -10) should be valid")
	var placed_granary_success = placement_handler.confirm_placement()
	assert(placed_granary_success, "Granary placement confirmation must succeed")
	assert(eco_mgr.resources["Gold"] == initial_gold - 100, "Granary should cost 100 Gold")
	print("      Granary placed at (15, 0, -10). Gold deducted properly: %d" % eco_mgr.resources["Gold"])
	
	placement_handler.start_placement("house")
	placement_handler.update_ghost_position(Vector3(-15.0, 0.0, -10.0))
	var placed_house_success = placement_handler.confirm_placement()
	assert(placed_house_success, "Tenement placement confirmation must succeed")
	assert(eco_mgr.resources["Gold"] == initial_gold - 160, "Tenement should cost 60 Gold")
	print("      Mudbrick Tenement placed at (-15, 0, -10). Gold remaining: %d" % eco_mgr.resources["Gold"])
	
	# -------------------------------------------------------------
	# STEP 2: Test Construction Lifecycle & State Transitions
	# -------------------------------------------------------------
	print("\n[TEST 2/6] Testing Construction Lifecycle Progress...")
	
	var buildings = root.get_tree().get_nodes_in_group("PlayerBuildings")
	var granary_node: Building = null
	var house_node: Building = null
	for b in buildings:
		if b.building_id == "granary": granary_node = b
		elif b.building_id == "mudbrick_house": house_node = b
		
	assert(granary_node != null, "Granary instance must exist in PlayerBuildings")
	assert(granary_node.state == Building.State.UNDER_CONSTRUCTION, "Placed structure must start UNDER_CONSTRUCTION")
	assert(granary_node.scaffolding != null and granary_node.scaffolding.visible, "Scaffolding must be visible during construction")
	assert(granary_node.model_root != null and not granary_node.model_root.visible, "ModelRoot must be hidden during construction")
	print("      Granary starts in UNDER_CONSTRUCTION. Scaffolding is active.")
	
	# Accelerate construction for testing
	granary_node.construction_time = 0.5
	house_node.construction_time = 0.5
	
	await create_timer(0.6).timeout
	
	assert(granary_node.state == Building.State.COMPLETED, "Granary must transition to COMPLETED")
	assert(granary_node.model_root.visible, "ModelRoot must be visible after construction completes")
	assert(not granary_node.scaffolding.visible, "Scaffolding must be hidden after construction completes")
	print("      Construction completed! Visual state switched to completed mesh.")
	
	# -------------------------------------------------------------
	# STEP 3: Test Economic & Population Outputs
	# -------------------------------------------------------------
	print("\n[TEST 3/6] Testing Economic Outputs & Population Buffs...")
	
	var new_grain_delta = eco_mgr.deltas.get("Grain", 0.0)
	print("      Granary Grain Delta: %.1f -> %.1f (+%.1f)" % [initial_grain_delta, new_grain_delta, new_grain_delta - initial_grain_delta])
	assert(new_grain_delta >= initial_grain_delta + 15.0, "Granary must provide +15 Grain/s")
	
	var new_housing = pop_mgr.max_housing
	print("      Housing Capacity: %d -> %d (+%d)" % [initial_housing, new_housing, new_housing - initial_housing])
	assert(new_housing > initial_housing, "Mudbrick Tenement must increase max housing capacity")
	
	# -------------------------------------------------------------
	# STEP 4: Test Barracks Placement, Recruitment & Rally Points
	# -------------------------------------------------------------
	print("\n[TEST 4/6] Testing Barracks Muster & Rally Point Auto-March...")
	
	placement_handler.start_placement("barracks")
	placement_handler.update_ghost_position(Vector3(0.0, 0.0, -18.0))
	placement_handler.confirm_placement()
	
	var barracks_node: Building = null
	for b in root.get_tree().get_nodes_in_group("PlayerBuildings"):
		if b.building_id == "barracks": barracks_node = b
		
	assert(barracks_node != null, "Barracks instance must exist")
	barracks_node.complete_construction() # Force immediate completion
	
	# Set rally point 20 units south
	var target_rally = Vector3(0.0, 0.0, 5.0)
	barracks_node.set_rally_point(target_rally)
	assert(barracks_node.rally_point == target_rally, "Rally point must match assigned coordinates")
	print("      Barracks set rally point to: %s" % str(target_rally))
	
	# Recruit Spearman cohort
	var initial_recruits = pop_mgr.conscription_pool
	var recruited_spearman = barracks_node.recruit_unit("spearman")
	assert(recruited_spearman != null, "Recruited spearman cohort must be spawned")
	assert(pop_mgr.conscription_pool == initial_recruits - 1, "Conscription pool must decrease by 1")
	assert(recruited_spearman.target_destination == target_rally, "Recruited unit must be automatically ordered to rally point")
	print("      Recruited Spearman successfully. Target destination matches rally point.")
	
	# Let unit march toward rally point
	for step in range(30):
		await create_timer(0.05).timeout
	print("      Recruit marched from (%s) toward rally (%s). Current Pos: %s" % [
		str(barracks_node.global_position), str(target_rally), str(recruited_spearman.global_position)
	])
	assert(recruited_spearman.global_position.z > barracks_node.global_position.z + 5.0, "Unit must move toward rally point")
	
	# -------------------------------------------------------------
	# STEP 5: Test Dynamic NavMesh Update & Obstacle Avoidance
	# -------------------------------------------------------------
	print("\n[TEST 5/6] Testing Dynamic NavMesh Re-Bake & Building Avoidance...")
	
	# Spawn a unit north of the Barracks
	var unit_scene = load("res://scenes/units/Unit.tscn")
	var nav_test_unit = unit_scene.instantiate()
	nav_test_unit.unit_type = "spearman"
	nav_test_unit.team_id = 0
	nav_test_unit.position = Vector3(0.0, 0.0, -32.0) # North of barracks at (0, 0, -18)
	world.add_child(nav_test_unit)
	
	await create_timer(0.1).timeout
	
	# Order unit to move straight through where the Barracks is located to (0, 0, 0)
	var move_dest = Vector3(0.0, 0.0, 0.0)
	nav_test_unit.set_target_destination(move_dest)
	
	print("      Unit pathing from (0, 0, -32) to (0, 0, 0) across Barracks at (0, 0, -18)...")
	for step in range(120):
		await create_timer(0.05).timeout
		if nav_test_unit.global_position.distance_to(move_dest) < 3.0:
			break
			
	var final_dist_to_dest = nav_test_unit.global_position.distance_to(move_dest)
	print("      Unit final position: %s, Distance to destination: %.2f" % [str(nav_test_unit.global_position), final_dist_to_dest])
	assert(final_dist_to_dest < 4.0, "Unit must successfully navigate around the newly built Barracks to reach destination")
	
	# -------------------------------------------------------------
	# STEP 6: Test Damage & Destruction
	# -------------------------------------------------------------
	print("\n[TEST 6/6] Testing Structure Damage & Destruction Cleanup...")
	
	var pre_destroy_grain = eco_mgr.deltas.get("Grain", 0.0)
	granary_node.take_damage(granary_node.max_health * 0.7)
	assert(granary_node.state == Building.State.DAMAGED, "Building at 30% health must enter DAMAGED state")
	print("      Building correctly transitions to DAMAGED state.")
	
	# Destroy granary
	granary_node.take_damage(granary_node.max_health)
	await create_timer(0.1).timeout
	
	var post_destroy_grain = eco_mgr.deltas.get("Grain", 0.0)
	print("      Granary Destroyed. Grain Delta: %.1f -> %.1f" % [pre_destroy_grain, post_destroy_grain])
	assert(post_destroy_grain <= pre_destroy_grain - 15.0, "Destroyed Granary must reclaim economic output delta")
	
	print("==================================================")
	print(">>> ALL 6/6 BUILDING SYSTEM TESTS PASSED SUCCESSFULLY! <<<")
	print("==================================================")
	quit()
