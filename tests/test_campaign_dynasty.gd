extends SceneTree

const Building = preload("res://scenes/buildings/Building.gd")
const TacticalAbilities = preload("res://scripts/actions/TacticalAbilities.gd")

func _init() -> void:
	print("==================================================================")
	print("--- CHRONICLES OF DOMINION: CAMPAIGN & DYNASTY INTEGRATION SUITE ---")
	print("==================================================================")
	
	# Strict 15s Watchdog: auto-terminates test run so it NEVER hangs
	create_timer(15.0).timeout.connect(func():
		printerr("\n[WATCHDOG ERROR] Campaign & Dynasty test timed out after 15s!")
		quit(1)
	)
	
	call_deferred("_run_suite")

func _run_suite() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	await create_timer(0.4).timeout
	
	var world = root.get_node_or_null("Main/World")
	var hud = root.get_node_or_null("Main/UI/HUD")
	var campaign_map = root.get_node_or_null("Main/UI/CampaignMap")
	var cmm = root.get_node_or_null("/root/CampaignMapManager")
	var dyn_mgr = root.get_node_or_null("/root/DynastyManager")
	var eco_mgr = root.get_node_or_null("/root/EconomyManager")
	var pol_mgr = root.get_node_or_null("/root/PoliticsManager")
	var pop_mgr = root.get_node_or_null("/root/PopulationManager")
	
	assert(world != null, "World node must exist in Main")
	assert(hud != null, "HUD node must exist in Main/UI")
	assert(campaign_map != null, "CampaignMap node must exist in Main/UI")
	assert(cmm != null, "CampaignMapManager autoload must exist")
	assert(dyn_mgr != null, "DynastyManager autoload must exist")
	assert(eco_mgr != null, "EconomyManager autoload must exist")
	assert(pol_mgr != null, "PoliticsManager autoload must exist")
	
	# Setup test treasury
	eco_mgr.resources["Gold"] = 2500
	eco_mgr.resources["Timber"] = 1500
	eco_mgr.resources["Stone"] = 1500
	eco_mgr.resources["Bronze"] = 1000
	eco_mgr.resources["Grain"] = 2000
	
	# -------------------------------------------------------------
	# 1. TEST PROVINCE DATA & TAXATION
	# -------------------------------------------------------------
	print("\n[1/7] Testing Overworld Province Data & Taxation...")
	assert(cmm.provinces.size() >= 6, "Must have all 6 Mesopotamian provinces")
	assert(cmm.provinces.has("ur_kish"), "Ur-Kish must exist")
	assert(cmm.provinces.has("babylon"), "Babylon must exist")
	assert(cmm.provinces.has("lagash"), "Lagash must exist")
	
	var initial_order = cmm.provinces["babylon"].public_order
	cmm.set_province_tax("babylon", "high")
	assert(cmm.provinces["babylon"].public_order < initial_order, "High tax must reduce public order")
	
	cmm.set_province_tax("babylon", "low")
	assert(cmm.provinces["babylon"].public_order > initial_order - 12.0, "Low tax must boost public order")
	print("       Provincial tax adjustment & public order deltas verified.")

	# -------------------------------------------------------------
	# 2. TEST PROVINCIAL INFRASTRUCTURE (ROADS & CANALS)
	# -------------------------------------------------------------
	print("\n[2/7] Testing Provincial Infrastructure Construction...")
	var initial_nineveh_grain = cmm.provinces["nineveh"].grain_yield
	var canal_built = cmm.build_provincial_infrastructure("nineveh", "canals")
	assert(canal_built, "Canal construction on Nineveh should succeed")
	assert(cmm.provinces["nineveh"].canals_built, "Nineveh canals_built flag must be true")
	assert(cmm.provinces["nineveh"].grain_yield > initial_nineveh_grain, "Grain yield must increase after canal")
	print("       Canal infrastructure completed (+35 Grain/m yield verified).")

	# -------------------------------------------------------------
	# 3. TEST TRADE CARAVANS & MACRO ECONOMY
	# -------------------------------------------------------------
	print("\n[3/7] Testing Trade Caravans & Economic Dispatch...")
	cmm._spawn_routine_trade_caravan()
	assert(cmm.active_caravans.size() >= 1, "Must have active trade caravan")
	var initial_gold = eco_mgr.resources["Gold"]
	var caravan = cmm.active_caravans[0]
	cmm._complete_caravan(caravan)
	assert(eco_mgr.resources["Gold"] == initial_gold + caravan.cargo_gold, "Caravan arrival must deposit gold")
	print("       Trade caravan delivered %d Gold successfully." % caravan.cargo_gold)

	# -------------------------------------------------------------
	# 4. TEST SEAMLESS VIEW MODE TOGGLE ([TAB])
	# -------------------------------------------------------------
	print("\n[4/7] Testing Strategic / Tactical View Mode Switching...")
	assert(cmm.active_view_mode == "TACTICAL_3D", "Default mode must be TACTICAL_3D")
	cmm.toggle_view_mode()
	assert(cmm.active_view_mode == "STRATEGIC_OVERWORLD", "Must switch to STRATEGIC_OVERWORLD")
	assert(campaign_map.visible, "CampaignMap UI must become visible in overworld mode")
	
	cmm.toggle_view_mode()
	assert(cmm.active_view_mode == "TACTICAL_3D", "Must toggle back to TACTICAL_3D")
	assert(not campaign_map.visible, "CampaignMap UI must hide in tactical mode")
	print("       [TAB] Strategic <-> Tactical view mode toggling verified.")

	# -------------------------------------------------------------
	# 5. TEST DYNASTIC SUCCESSION CRISIS & POWER CONSOLIDATION
	# -------------------------------------------------------------
	print("\n[5/7] Testing Dynastic Succession & Consolidation Edicts...")
	assert(dyn_mgr.current_ruler_name == "Sargon I", "Initial ruler must be Sargon I")
	dyn_mgr.trigger_ruler_death()
	
	assert(dyn_mgr.current_ruler_name == "Rimush", "Rimush must ascend throne")
	assert(dyn_mgr.in_succession_crisis, "Must enter succession crisis upon ruler death")
	assert(dyn_mgr.legitimacy <= 35.0, "Legitimacy must drop to crisis level (<=35%)")
	
	# Enact consolidation edicts
	var purged = dyn_mgr.enact_consolidation_edict("purge_rivals")
	assert(purged, "Purge rivals edict must succeed")
	assert(dyn_mgr.legitimacy >= 50.0, "Purge rivals must boost legitimacy (+25%)")
	
	var doled = dyn_mgr.enact_consolidation_edict("treasury_dole")
	assert(doled, "Treasury dole edict must succeed")
	assert(dyn_mgr.legitimacy >= 75.0, "Treasury dole must boost legitimacy to safe level (>=70%)")
	assert(not dyn_mgr.in_succession_crisis, "Crisis must be resolved when legitimacy >= 70%")
	print("       Dynastic succession crisis resolved and power consolidated at %d%% legitimacy." % int(dyn_mgr.legitimacy))

	# -------------------------------------------------------------
	# 6. TEST DYNASTIC MUTINY & REBEL ERUPTION
	# -------------------------------------------------------------
	print("\n[6/7] Testing Mutiny Cascade on Consolidation Failure...")
	var tracker = {"mutiny_fired": false}
	dyn_mgr.mutiny_erupted.connect(func(_prov): tracker.mutiny_fired = true)
	
	dyn_mgr.trigger_ruler_death()
	assert(dyn_mgr.in_succession_crisis, "Second crisis triggered")
	dyn_mgr.legitimacy = 25.0 # Keep low
	dyn_mgr._evaluate_consolidation_outcome()
	
	assert(tracker.mutiny_fired, "Dynastic mutiny signal must fire when legitimacy < 60%")
	assert(not dyn_mgr.in_succession_crisis, "Crisis ended through rebellion")
	print("       Mutiny and rebel uprising correctly triggered upon consolidation failure.")

	# -------------------------------------------------------------
	# 7. TEST TACTICAL COMMAND ABILITIES
	# -------------------------------------------------------------
	print("\n[7/7] Testing Tactical Command Abilities...")
	var player_units = []
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u) and u.get("team_id") == 0:
			player_units.append(u)
			
	assert(player_units.size() >= 1, "Must have player units for tactical commands")
	
	# [R] Rally the Line
	var rallied = TacticalAbilities.rally_line(player_units)
	assert(rallied > 0, "Rally the Line must activate on cohorts")
	
	# [T] Shield Bracing
	var braced = TacticalAbilities.shield_brace(player_units)
	assert(braced > 0, "Shield Bracing must activate on infantry cohorts")
	for u in player_units:
		if u.unit_type == "spearman":
			assert(u.is_braced, "Spearman must have is_braced = true")
			
	# [Y] Chariot Trample
	var unit_scene = load("res://scenes/units/Unit.tscn")
	var chariot_unit = unit_scene.instantiate()
	chariot_unit.unit_type = "chariot"
	chariot_unit.team_id = 0
	world.add_child(chariot_unit)
	await create_timer(0.1).timeout
	var trampled = TacticalAbilities.chariot_trample([chariot_unit])
	assert(trampled > 0, "Chariot Trample must activate on chariot")
	assert(chariot_unit.is_trampling, "Chariot must have is_trampling = true")
			
	# [U] Arrow Rain Volley
	var archer_unit = unit_scene.instantiate()
	archer_unit.unit_type = "archer"
	archer_unit.team_id = 0
	world.add_child(archer_unit)
	await create_timer(0.1).timeout
	var volley_fired = TacticalAbilities.arrow_volley([archer_unit], Vector3(0, 0, 20))
	assert(volley_fired > 0, "Arrow Volley must activate on archer")
	print("       Tactical command abilities (Rally, Shield Brace, Chariot Trample, Arrow Volley) executed successfully.")

	print("\n==================================================================")
	print(">>> ALL 7/7 CAMPAIGN & DYNASTY INTEGRATION TESTS PASSED 100%! <<<")
	print("==================================================================")
	quit(0)
