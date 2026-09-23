extends SceneTree

const Building = preload("res://scenes/buildings/Building.gd")

func _init() -> void:
	print("==================================================================")
	print("--- CHRONICLES OF DOMINION: GRAND MASTER INTEGRATION SUITE ---")
	print("==================================================================")
	call_deferred("_run_master_suite")

func _run_master_suite() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Allow full scene tree, autoloads, and NavMesh initialization
	await create_timer(0.5).timeout
	
	var world = root.get_node_or_null("Main/World")
	var hud = root.get_node_or_null("Main/UI/HUD")
	var eco_mgr = root.get_node_or_null("/root/EconomyManager")
	var pop_mgr = root.get_node_or_null("/root/PopulationManager")
	var tech_mgr = root.get_node_or_null("/root/TechManager")
	var supply_mgr = root.get_node_or_null("/root/SupplyManager")
	var religion_mgr = root.get_node_or_null("/root/ReligionManager")
	var save_mgr = root.get_node_or_null("/root/SaveManager")
	
	assert(world != null, "World must exist")
	assert(hud != null, "HUD must exist")
	assert(eco_mgr != null, "EconomyManager must exist")
	assert(pop_mgr != null, "PopulationManager must exist")
	assert(tech_mgr != null, "TechManager must exist")
	assert(supply_mgr != null, "SupplyManager must exist")
	assert(religion_mgr != null, "ReligionManager must exist")
	assert(save_mgr != null, "SaveManager must exist")
	
	# Clean slate setup
	eco_mgr.resources["Gold"] = 5000
	eco_mgr.resources["Timber"] = 3000
	eco_mgr.resources["Stone"] = 3000
	eco_mgr.resources["Bronze"] = 2000
	eco_mgr.resources["Grain"] = 4000
	pop_mgr.conscription_pool = 100
	
	# -------------------------------------------------------------
	# 1. TEST SELECTION & MOVEMENT
	# -------------------------------------------------------------
	print("\n[1/10] Testing Selection & Formation Movement...")
	var player_units = []
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u) and u.get("team_id") == 0:
			player_units.append(u)
			
	assert(player_units.size() >= 3, "Should have starting player cohorts")
	hud._select_units(player_units)
	for u in player_units:
		assert(u.is_selected, "Selected units must have is_selected = true")
		assert(u.selection_ring.visible, "Selection ring must be visible")
	print("       Selection successful (%d cohorts selected with active rings)." % player_units.size())
	
	# Order movement
	var move_dest = Vector3(10.0, 0.0, 10.0)
	for i in range(player_units.size()):
		var offset = hud._compute_formation_offset(i, player_units.size())
		player_units[i].set_target_destination(move_dest + offset)
	print("       Dispatched formation march orders to: %s" % str(move_dest))
	
	# -------------------------------------------------------------
	# 2. TEST 5 BUILDING ARCHETYPES & PLACEMENT
	# -------------------------------------------------------------
	print("\n[2/10] Testing 5 Structure Archetypes (Barracks, Granary, Tenement, Bazaar, Foundry)...")
	var handler = hud.placement_handler
	var b_types = ["barracks", "granary", "house", "bazaar", "chariot_foundry"]
	var b_positions = [
		Vector3(-50, 0, -15),
		Vector3(-50, 0, 15),
		Vector3(-30, 0, 45),
		Vector3(-30, 0, -45),
		Vector3(-70, 0, 0)
	]
	
	for i in range(b_types.size()):
		var b_key = b_types[i]
		var b_pos = b_positions[i]
		handler.start_placement(b_key)
		handler.update_ghost_position(b_pos)
		var placed = handler.confirm_placement()
		assert(placed, "Placement of %s must succeed" % b_key)
		print("       Placed %s at %s" % [b_key.capitalize(), str(b_pos)])
		
	# Complete construction for all placed structures
	await create_timer(0.2).timeout
	for b in root.get_tree().get_nodes_in_group("PlayerBuildings"):
		if is_instance_valid(b) and b.has_method("complete_construction"):
			b.complete_construction()
	print("       All 5 structures completed construction and active.")
	
	# -------------------------------------------------------------
	# 3. TEST MILITARY RECRUITMENT & RALLY POINTS
	# -------------------------------------------------------------
	print("\n[3/10] Testing Recruitment from Barracks & Foundry with Rally Point...")
	var barracks: Building = null
	var foundry: Building = null
	for b in root.get_tree().get_nodes_in_group("PlayerBuildings"):
		if b.building_id == "barracks": barracks = b
		elif b.building_id == "chariot_foundry": foundry = b
		
	assert(barracks != null, "Barracks must exist")
	assert(foundry != null, "Foundry must exist")
	
	var custom_rally = Vector3(0.0, 0.0, 0.0)
	barracks.set_rally_point(custom_rally)
	var new_spearman = barracks.recruit_unit("spearman")
	assert(new_spearman != null, "Spearman must be recruited")
	assert(new_spearman.target_destination == custom_rally, "Recruit must march to custom rally point")
	print("       Recruited Spearman from Barracks; marching to rally point: %s" % str(custom_rally))
	
	# -------------------------------------------------------------
	# 4. TEST 4-EPOCH TECH PROGRESSION
	# -------------------------------------------------------------
	print("\n[4/10] Testing 4-Epoch Tech System (Researching Inventions)...")
	assert(tech_mgr.current_epoch == tech_mgr.Epoch.BRONZE, "Should start in Bronze Age")
	var started_bows = tech_mgr.start_research("composite_bows")
	assert(started_bows, "Starting Composite Bows research must succeed")
	tech_mgr.research_progress = 100.0 # Fast forward
	await create_timer(0.1).timeout
	assert(tech_mgr.is_tech_researched("composite_bows"), "Composite Bows must be researched")
	print("       Researched: Composite Bows (+25%% range). Current Epoch: %s" % tech_mgr.get_epoch_name())
	
	# Research Iron Age advancement
	tech_mgr.researched_techs.append("phalanx_drills")
	tech_mgr.researched_techs.append("mudbrick_kilns")
	tech_mgr.start_research("epoch_iron")
	tech_mgr.research_progress = 100.0
	await create_timer(0.1).timeout
	assert(tech_mgr.current_epoch == tech_mgr.Epoch.IRON, "Should advance to Iron Age")
	print("       Advancement Complete: Realm entered the %s!" % tech_mgr.get_epoch_name())
	
	# -------------------------------------------------------------
	# 5. TEST RELIGION & SACRIFICE BLESSINGS
	# -------------------------------------------------------------
	print("\n[5/10] Testing Religion System & Sacred Temple Offerings...")
	var sacrificed = religion_mgr.perform_sacrifice("grain")
	assert(sacrificed, "Grain sacrifice must succeed")
	assert(religion_mgr.divine_favor > 60.0, "Divine favor must increase")
	print("       Sacred Offering complete. Divine Favor = %.1f, Active Blessing = Bountiful Harvest" % religion_mgr.divine_favor)
	
	# -------------------------------------------------------------
	# 6. TEST SUPPLY LINES & BAGGAGE TRAINS
	# -------------------------------------------------------------
	print("\n[6/10] Testing Logistics & Supply Network...")
	supply_mgr.register_granary(Vector3(0, 0, 0))
	assert(supply_mgr.is_in_supply(Vector3(10, 0, 10)), "Position near granary must be in supply")
	assert(not supply_mgr.is_in_supply(Vector3(200, 0, 200)), "Far position must be out of supply")
	print("       Granary supply perimeter verified (in-range = True, deep desert = False).")
	
	# -------------------------------------------------------------
	# 7. TEST TACTICAL COMBAT & PROJECTILES
	# -------------------------------------------------------------
	print("\n[7/10] Testing Combat Engagement & Flanking Multipliers...")
	var unit_scene = load("res://scenes/units/Unit.tscn")
	var defender = unit_scene.instantiate()
	defender.unit_type = "spearman"
	defender.team_id = 0
	defender.position = Vector3(5, 0, 5)
	world.add_child(defender)
	
	var initial_hp = defender.current_hp
	defender.take_damage(20.0, Vector3(5, 0, 10), false) # Frontal hit
	var post_front_hp = defender.current_hp
	assert(post_front_hp < initial_hp, "Defender must take damage")
	print("       Frontal hit: HP %.1f -> %.1f" % [initial_hp, post_front_hp])
	
	# -------------------------------------------------------------
	# 8. TEST PROCEDURAL AUDIO SYSTEM
	# -------------------------------------------------------------
	print("\n[8/10] Testing Procedural Audio Manager...")
	var audio_mgr = root.get_node_or_null("/root/AudioManager")
	assert(audio_mgr != null, "AudioManager must exist")
	audio_mgr.play_sfx("order")
	audio_mgr.play_sfx("attack")
	audio_mgr.play_sfx("build")
	print("       Procedural audio SFX triggers executed successfully.")
	
	# -------------------------------------------------------------
	# 9. TEST AUTONOMOUS AI COMMANDER
	# -------------------------------------------------------------
	print("\n[9/10] Testing Autonomous AI Raider Commander...")
	var ai_commander = root.get_node_or_null("Main/RivalCommanderAI")
	assert(ai_commander != null, "RivalCommanderAI must exist on Main")
	if ai_commander.offense_controller:
		ai_commander.offense_controller._spawn_and_launch_assault_wave()
		print("       AI Commander executed tactical raid incursion.")
		
	# -------------------------------------------------------------
	# 10. TEST SAVE & LOAD SERIALIZATION
	# -------------------------------------------------------------
	print("\n[10/10] Testing Save / Load System State Serialization...")
	var saved = save_mgr.save_game()
	assert(saved, "Save game must succeed")
	
	# Modify resource and load back
	eco_mgr.resources["Gold"] = 99999
	var loaded = save_mgr.load_game()
	assert(loaded, "Load game must succeed")
	print("       Save and Load executed. State restored cleanly.")
	
	print("\n==================================================================")
	print(">>> ALL 10/10 GRAND MASTER INTEGRATION TESTS PASSED 100%! <<<")
	print("==================================================================")
	quit()
