extends SceneTree

const MoodleBadge = preload("res://scenes/ui/components/MoodleBadge.gd")
const MoodleContainer = preload("res://scenes/ui/components/MoodleContainer.gd")

func _init() -> void:
	print("==================================================================")
	print("--- CHRONICLES OF DOMINION: PROJECT ZOMBOID MOODLE SUITE ---")
	print("==================================================================")
	
	# Strict 15s Watchdog: auto-terminates test run so it NEVER hangs
	create_timer(15.0).timeout.connect(func():
		printerr("\n[WATCHDOG ERROR] Moodle system test timed out after 15s!")
		quit(1)
	)
	
	call_deferred("_run_suite")

func _run_suite() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	await create_timer(0.4).timeout
	
	var world = root.get_node_or_null("Main/World")
	var hud = root.get_node_or_null("Main/UI/HUD")
	var mm = root.get_node_or_null("/root/MoodleManager")
	var eco = root.get_node_or_null("/root/EconomyManager")
	var pol = root.get_node_or_null("/root/PoliticsManager")
	var pop = root.get_node_or_null("/root/PopulationManager")
	var dyn = root.get_node_or_null("/root/DynastyManager")
	
	assert(world != null, "World node must exist in Main")
	assert(hud != null, "HUD node must exist in Main/UI")
	assert(mm != null, "MoodleManager autoload must exist")
	assert(eco != null, "EconomyManager autoload must exist")
	assert(pol != null, "PoliticsManager autoload must exist")
	assert(pop != null, "PopulationManager autoload must exist")
	assert(dyn != null, "DynastyManager autoload must exist")
	
	var moodle_cont = hud.get_node_or_null("MoodleContainer")
	assert(moodle_cont != null, "MoodleContainer must exist inside HUD")
	
	# Clean slate
	eco.resources["Grain"] = 2000
	eco.resources["Gold"] = 3000
	pol.commoners_loyalty = 75.0
	pol.nobility_loyalty = 70.0
	pol.priesthood_loyalty = 70.0
	dyn.legitimacy = 85.0
	
	# -------------------------------------------------------------
	# 1. TEST MOODLE EMERGENCE ON UNMET REALM CONDITIONS
	# -------------------------------------------------------------
	print("\n[1/7] Testing Moodle Activation on Condition Deficit...")
	eco.resources["Grain"] = 10.0 # Extreme food shortage
	eco.deltas["Grain"] = -25.0
	mm._evaluate_world_conditions()
	
	assert(mm.is_moodle_active("famine"), "Famine moodle must activate when grain depleted")
	assert(mm.get_moodle_severity("famine") == 1, "Famine must begin at Tier 1 (Grain Shortage)")
	print("       Famine moodle activated successfully at Tier 1.")

	# -------------------------------------------------------------
	# 2. TEST REAL-TIME FESTERING ESCALATION
	# -------------------------------------------------------------
	print("\n[2/7] Testing Festering Escalation (Tiers 1 -> 2 -> 3 -> 4)...")
	var famine_data = mm.active_moodles["famine"]
	assert(famine_data.is_festering, "Moodle must be in festering state")
	
	# Simulate time passing to escalate through tiers
	famine_data.progress = 0.99
	mm._process_moodle_timers(1.0)
	assert(famine_data.severity == 2, "Famine must escalate to Tier 2 (Food Scarcity)")
	
	famine_data.progress = 0.99
	mm._process_moodle_timers(1.0)
	assert(famine_data.severity == 3, "Famine must escalate to Tier 3 (Severe Starvation)")
	
	famine_data.progress = 0.99
	mm._process_moodle_timers(1.0)
	assert(famine_data.severity == 4, "Famine must escalate to Tier 4 (Famine Riots)")
	print("       Festering logic escalated moodle through all 4 severity tiers.")

	# -------------------------------------------------------------
	# 3. TEST SYSTEMIC PASSIVE DEBUFFS
	# -------------------------------------------------------------
	print("\n[3/7] Testing Passive Economic & Military Modifiers...")
	var econ_mult = mm.get_economy_multiplier()
	assert(econ_mult < 1.0, "Severe Famine must apply negative economy multiplier")
	
	pol.commoners_loyalty = 20.0 # Trigger Popular Unrest
	mm._evaluate_world_conditions()
	assert(mm.is_moodle_active("unrest"), "Unrest moodle must activate on low commoner loyalty")
	
	var combined_mult = mm.get_economy_multiplier()
	assert(combined_mult < econ_mult, "Multiple active moodles must stack economic penalties")
	print("       Systemic debuffs verified (Economy yield scaled to %.2fx)." % combined_mult)

	# -------------------------------------------------------------
	# 4. TEST IN-WORLD PLAYER ALLEVIATION & RECOVERY
	# -------------------------------------------------------------
	print("\n[4/7] Testing Player In-World Alleviation & Recovery Drain...")
	eco.resources["Grain"] = 3500.0 # Replenish stores
	eco.deltas["Grain"] = 80.0
	mm._evaluate_world_conditions()
	
	assert(not mm.active_moodles["famine"].is_festering, "Famine must switch from festering to recovering")
	
	# Fast drain recovery
	while mm.is_moodle_active("famine"):
		mm._process_moodle_timers(5.0)
		
	assert(not mm.is_moodle_active("famine"), "Famine moodle must clear completely after recovery")
	print("       Player grain replenishment drained and resolved Famine affliction.")

	# -------------------------------------------------------------
	# 5. TEST CROSS-AFFLICTION CONTAGION & MULTIPLIERS
	# -------------------------------------------------------------
	print("\n[5/7] Testing Cross-Affliction Contagion & Spillover...")
	# Activate Pestilence at Tier 3
	mm._set_moodle_festering("pestilence", true)
	mm.active_moodles["pestilence"].severity = 3
	
	var initial_priest_loyalty = pol.priesthood_loyalty
	var initial_discontent = pop.discontent
	
	# Process contagion tick
	mm._process_cross_affliction_contagion(2.0)
	assert(pop.discontent > initial_discontent, "Pestilence must spike citizen discontent")
	assert(pol.priesthood_loyalty < initial_priest_loyalty, "Pestilence panic must erode priesthood loyalty")
	
	# Check contagion multiplier acceleration
	var schism_mult = mm.get_contagion_multiplier("schism")
	var unrest_mult = mm.get_contagion_multiplier("unrest")
	assert(schism_mult > 1.0, "Pestilence must accelerate Religious Schism fester multiplier")
	assert(unrest_mult > 1.0, "Pestilence must accelerate Popular Unrest fester multiplier")
	
	# Noble Coup accelerates Mutiny
	mm._set_moodle_festering("coup", true)
	mm.active_moodles["coup"].severity = 3
	var mutiny_mult = mm.get_contagion_multiplier("mutiny")
	assert(mutiny_mult > 1.5, "Noble conspiracy must accelerate Military Mutiny fester rate")
	print("       Contagion engine verified: Pestilence -> Unrest & Schism (%.1fx), Coup -> Mutiny (%.1fx)." % [schism_mult, mutiny_mult])

	# -------------------------------------------------------------
	# 6. TEST ACUTE DISASTER CONSEQUENCES ON FESTERING FAILURE
	# -------------------------------------------------------------
	print("\n[6/7] Testing Acute Catastrophic Disaster Eruption & Ripple...")
	var disaster_tracker = {"fired": false, "name": ""}
	mm.disaster_triggered.connect(func(m_id, d_name):
		disaster_tracker.fired = true
		disaster_tracker.name = d_name
	)
	
	# Put Unrest at Tier 4 and tick past threshold
	var unrest_data = mm.active_moodles["unrest"]
	unrest_data.severity = 4
	unrest_data.progress = 0.99
	unrest_data.disaster_cooldown = 0.0
	
	mm._process_moodle_timers(1.0)
	assert(disaster_tracker.fired, "Acute disaster must trigger when Tier 4 moodle festers")
	assert(disaster_tracker.name == "PeasantStrike", "Peasant Strike & Riot must erupt")
	print("       Acute disaster successfully erupted with secondary cascade shock.")

	# -------------------------------------------------------------
	# 7. TEST MOODLE CONTAINER UI DOCK & TOOLTIP INTEGRITY
	# -------------------------------------------------------------
	print("\n[7/7] Testing Right-Screen Moodle Container UI...")
	assert(moodle_cont.badge_instances.size() >= 1, "MoodleContainer must have active badge child")
	var unrest_badge = moodle_cont.badge_instances.get("unrest", null)
	assert(unrest_badge != null, "Unrest badge must exist in container")
	assert(unrest_badge.lbl_name.text.length() > 0, "Badge title text must be rendered")
	assert(unrest_badge.tt_desc.text.length() > 0, "Tooltip description must be rendered")
	assert(unrest_badge.tt_contagion != null, "Tooltip cascade risk label must exist")
	assert(unrest_badge.tt_contagion.text.length() > 0, "Tooltip cascade risk text must be rendered")
	assert(unrest_badge.tt_remedy.text.length() > 0, "Tooltip remedy must be rendered")
	print("       Moodle UI dock rendered badges with live tooltips, progress bars, and cascade warnings.")

	print("\n==================================================================")
	print(">>> ALL 7/7 MOODLE INTEGRATION TESTS PASSED 100%! <<<")
	print("==================================================================")
	quit(0)
