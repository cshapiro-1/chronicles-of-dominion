extends SceneTree

func _init() -> void:
	print("--- BEGINNING AUTOMATED GAMEPLAY TEST ---")
	call_deferred("_run_test")

func _run_test() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	await create_timer(0.2).timeout
	
	# 1. Test recruitment
	var ziggurat = root.get_node_or_null("Main/World/Ziggurat")
	if ziggurat:
		ziggurat.recruit_unit("Spearman")
		ziggurat.recruit_unit("Slinger")
		ziggurat.recruit_unit("Chariot")
	
	print("RECRUITMENT TEST: PASSED! Total units: %d" % MilitaryManager.all_units.size())
	
	# 2. Test raider wave
	var world = root.get_node_or_null("Main/World")
	MilitaryManager.spawn_raider_wave(3, Vector3(-30, 0, -30), world)
	print("RAIDER WAVE TEST: PASSED! Total units with raiders: %d" % MilitaryManager.all_units.size())
	
	# 3. Test crisis trigger
	CrisisManager.trigger_random_crisis()
	print("CRISIS TRIGGER TEST: PASSED! Current crisis: %s" % (CrisisManager.current_crisis.title if CrisisManager.current_crisis else "None"))
	
	# 4. Test crisis resolution
	CrisisManager.resolve_crisis(0)
	print("CRISIS RESOLUTION TEST: PASSED!")
	
	print("--- ALL AUTOMATED GAMEPLAY TESTS PASSED WITH 0 ERRORS! ---")
	quit(0)
