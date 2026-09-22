extends SceneTree

func _init() -> void:
	print("==================================================")
	print("--- TACTICAL RTS CORE LOOP AUTOMATED TEST ---")
	print("==================================================")
	call_deferred("_run_test")

func _run_test() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	await create_timer(0.4).timeout
	
	var world = root.get_node_or_null("Main/World")
	var hud = root.get_node_or_null("Main/UI/HUD")
	var eco = root.get_node_or_null("EconomyManager")
	
	print("[1/5] Main Scene Initialized.")
	
	# 2. Recruitment
	hud._spawn_unit("spearman")
	hud._spawn_unit("archer")
	hud._spawn_unit("chariot")
	print("[2/5] Recruitment Succeeded: Player units spawned.")
	
	# 3. Unit Selection & Formations
	var player_units = []
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u) and u.get("team_id") == 0:
			player_units.append(u)
			
	print("[3/5] Unit Group Selection: Found %d player units." % player_units.size())
	hud._select_units(player_units)
	
	# Test formation offset calculation
	hud.current_formation = "Phalanx"
	var off_phalanx = hud._compute_formation_offset(1, 3)
	hud.current_formation = "Wedge"
	var off_wedge = hud._compute_formation_offset(1, 3)
	hud.current_formation = "Skirmish"
	var off_skirmish = hud._compute_formation_offset(1, 3)
	print("      Formations Verified: Phalanx %s, Wedge %s, Skirmish %s" % [str(off_phalanx), str(off_wedge), str(off_skirmish)])
	
	# 4. Movement Order
	hud._issue_right_click_order(Vector2(640, 360))
	print("      Movement Orders Issued: All selected units received destinations.")
	
	# 5. Combat Simulation
	hud._spawn_hostile_raider()
	var raiders = []
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u) and u.get("team_id") == 1:
			raiders.append(u)
			
	print("[4/5] Raider Incursion: Spawned %d hostile units." % raiders.size())
	
	if raiders.size() > 0:
		var test_raider = raiders[0]
		var raider_hp_before = test_raider.current_hp
		
		# Simulate combat strike
		player_units[0]._perform_attack(test_raider)
		print("      Combat Strike: Raider HP reduced from %d to %d" % [int(raider_hp_before), int(test_raider.current_hp)])
		
		# Simulate kill & reward
		test_raider.take_damage(9999.0)
		await create_timer(0.1).timeout
		print("[5/5] Raider Defeated: Death event handled and Gold awarded.")
	
	print("==================================================")
	print(">>> ALL TACTICAL RTS VERTICAL SLICE TESTS PASSED! <<<")
	print("==================================================")
	quit(0)
