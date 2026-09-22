extends SceneTree

func _init() -> void:
	print("==================================================")
	print("--- PLAYER-ACTION CRISIS SYSTEM VERIFICATION ---")
	print("==================================================")
	call_deferred("_run_test")

func _run_test() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	await create_timer(0.3).timeout
	
	var crisis_mgr = root.get_node_or_null("/root/CrisisManager")
	var politics_mgr = root.get_node_or_null("/root/PoliticsManager")
	var pop_mgr = root.get_node_or_null("/root/PopulationManager")
	var eco_mgr = root.get_node_or_null("/root/EconomyManager")
	
	# TEST 1: Crises do not trigger on idle time
	print("[1/4] Verifying no spontaneous timer crises on idle...")
	await create_timer(1.0).timeout
	assert(crisis_mgr.active_crisis == null, "Crisis should NOT trigger spontaneously without user action")
	print("      SUCCESS: System is idle with zero unsolicited crises.")
	
	# TEST 2: Excessive Urban Housing triggers Disease Outbreak
	print("[2/4] Testing Action Trigger: Rapid Urban Housing Expansion...")
	pop_mgr.add_urban_housing(3) # Pushes urban housing over density threshold
	await create_timer(0.1, true, false, true).timeout
	assert(crisis_mgr.active_crisis != null, "Urban expansion must trigger disease crisis")
	print("      Triggered Crisis: '%s'" % crisis_mgr.active_crisis.title)
	assert(crisis_mgr.active_crisis.title == "Pestilence in the Mudbrick Quarters", "Should be mudbrick pestilence")
	
	# Resolve choice 0 (Quarantine)
	crisis_mgr.resolve_crisis(0)
	print("      Resolved with quarantine. Active crisis cleared.")
	assert(crisis_mgr.active_crisis == null, "Crisis should be resolved")
	
	# TEST 3: Raising Church Tithes triggers Theocratic Overreach & Economic Drain
	print("[3/4] Testing Action Trigger: Raising Church Tithes...")
	politics_mgr.priesthood_loyalty = 60.0
	var gold_delta_before = eco_mgr.deltas.get("Gold", 80.0)
	politics_mgr.raise_tithes()
	politics_mgr.raise_tithes()
	await create_timer(0.1, true, false, true).timeout
	
	assert(eco_mgr.deltas.get("Gold", 0.0) < gold_delta_before, "Gold income rate must decrease from church drain")
	assert(crisis_mgr.active_crisis != null, "Excessive church power must trigger theocracy crisis")
	print("      Triggered Crisis: '%s'" % crisis_mgr.active_crisis.title)
	assert(crisis_mgr.active_crisis.title == "Theocratic Tithe Dominance", "Should be theocratic tithe dominance")
	
	# Resolve choice 1 (Assert Royal Sovereignty)
	crisis_mgr.resolve_crisis(1)
	print("      Resolved with royal sovereignty. Priesthood loyalty balanced, income reclaimed.")
	assert(crisis_mgr.active_crisis == null, "Crisis should be resolved")
	
	# TEST 4: Low Commoner Loyalty triggers Granary Bread Riots
	print("[4/4] Testing Action Trigger: Commoner Oppression & Low Bread...")
	politics_mgr.modify_estates(0.0, 0.0, -50.0) # Plummet commoner loyalty to 15%
	await create_timer(0.1, true, false, true).timeout
	assert(crisis_mgr.active_crisis != null, "Commoner starvation/oppression must trigger bread riots")
	print("      Triggered Crisis: '%s'" % crisis_mgr.active_crisis.title)
	assert(crisis_mgr.active_crisis.title == "Granary Bread Riots", "Should be granary bread riots")
	
	crisis_mgr.resolve_crisis(0)
	print("      Resolved with grain distribution.")
	assert(crisis_mgr.active_crisis == null, "Crisis should be resolved")
	
	print("==================================================")
	print(">>> ALL CAUSE-AND-EFFECT CRISIS TESTS PASSED! <<<")
	print("==================================================")
	quit(0)
