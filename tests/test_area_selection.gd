extends SceneTree

func _init() -> void:
	print("==================================================")
	print("--- COMPREHENSIVE AREA SELECTION TEST ---")
	print("==================================================")
	call_deferred("_run_test")

func _run_test() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	await create_timer(0.3).timeout
	
	var hud = root.get_node_or_null("Main/UI/HUD")
	var camera = root.get_viewport().get_camera_3d()
	var vp_size = root.get_viewport().get_visible_rect().size
	
	assert(hud != null, "HUD must exist")
	assert(camera != null, "Camera3D must exist")
	
	var player_units = []
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u) and u.get("team_id") == 0:
			player_units.append(u)
			
	print("[1/3] Found %d player units on the battlefield." % player_units.size())
	
	# Test 1: Individual targeted marquee box for EVERY visible unit
	var sel_handler = hud.selection_box
	var visible_units = []
	
	for u in player_units:
		if not camera.is_position_behind(u.global_position):
			var sp = camera.unproject_position(u.global_position)
			if sp.x >= 0 and sp.x <= vp_size.x and sp.y >= 0 and sp.y <= vp_size.y:
				visible_units.append(u)
				# Draw a small 40x40 marquee box around the unit
				sel_handler.start_drag(sp - Vector2(20, 20))
				sel_handler.update_drag(sp + Vector2(20, 20))
				var result = sel_handler.end_drag()
				assert(result.has(u), "Marquee box on %s must select it" % u.unit_type)
				
	print("[2/3] Targeted Unit Marquee Boxes: All %d visible units gathered with 100%% accuracy." % visible_units.size())
	
	# Test 2: Large Group Drag encompassing all visible units
	var min_sp = Vector2(9999, 9999)
	var max_sp = Vector2(-9999, -9999)
	for u in visible_units:
		var sp = camera.unproject_position(u.global_position)
		min_sp.x = min(min_sp.x, sp.x - 25)
		min_sp.y = min(min_sp.y, sp.y - 25)
		max_sp.x = max(max_sp.x, sp.x + 25)
		max_sp.y = max(max_sp.y, sp.y + 25)
		
	sel_handler.start_drag(min_sp)
	sel_handler.update_drag(max_sp)
	var group_gathered = sel_handler.end_drag()
	
	print("[3/3] Group Marquee Selection: Gathered %d / %d visible units." % [group_gathered.size(), visible_units.size()])
	assert(group_gathered.size() == visible_units.size(), "Group drag must gather all visible units inside box")
	
	print("==================================================")
	print(">>> ALL AREA SELECTION TESTS PASSED (100% PRECISION)! <<<")
	print("==================================================")
	quit(0)
