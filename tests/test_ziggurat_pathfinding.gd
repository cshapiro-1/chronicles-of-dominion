extends SceneTree

func _init() -> void:
	var f = FileAccess.open("res://test_output.txt", FileAccess.WRITE)
	f.store_line("--- TEST STARTED ---")
	f.close()
	call_deferred("_run_test")

func _run_test() -> void:
	var f = FileAccess.open("res://test_output.txt", FileAccess.READ_WRITE)
	f.seek_end()
	f.store_line("In _run_test...")
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	await create_timer(0.3).timeout
	var world = main_scene.get_node("World")
	var vanguard = world.get_node_or_null("Cohort_Spearmen_Vanguard")
	f.store_line("Vanguard: " + str(vanguard != null))
	if vanguard:
		vanguard.global_position = Vector3(-12.0, 0.0, 6.0)
		var dest = Vector3(24.0, 0.0, 6.0)
		vanguard.set_target_destination(dest)
		for step in range(80):
			await create_timer(0.05).timeout
			var pos = vanguard.global_position
			f.store_line("Step %d: pos=%s, dist=%.2f" % [step, str(pos), pos.distance_to(dest)])
			if pos.distance_to(dest) < 1.5:
				f.store_line("SUCCESS REACHED DEST!")
				break
	f.close()
	quit()
