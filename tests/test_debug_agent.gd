extends SceneTree

func _init() -> void:
	call_deferred("_test_debug")

func _test_debug() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	await create_timer(0.4).timeout
	var world = root.get_node("Main/World")
	var unit_scene = load("res://scenes/units/Unit.tscn")
	var u = unit_scene.instantiate()
	u.position = Vector3(-16.0, 0.0, 6.0)
	world.add_child(u)
	
	print("Unit added. Frame 0:")
	print("  Unit world navigation map: ", u.get_world_3d().navigation_map)
	print("  NavAgent node exists: ", u.nav_agent != null)
	
	u.set_target_destination(Vector3(28.0, 0.0, 6.0))
	print("  Immediately after set_target_destination:")
	print("    target_position = ", u.nav_agent.target_position)
	print("    get_next_path_position() = ", u.nav_agent.get_next_path_position())
	
	for f in range(5):
		await process_frame
		print("  Frame %d: get_next_path_position() = %s, dist_to_target = %.2f" % [
			f, str(u.nav_agent.get_next_path_position()), u.global_position.distance_to(u.target_destination)
		])
	print("  current_path count = ", u.nav_agent.get_current_navigation_path().size())
	for p in u.nav_agent.get_current_navigation_path():
		print("    Path pt: ", p)
		
	quit()
