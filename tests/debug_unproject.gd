extends SceneTree

func _init() -> void:
	call_deferred("_debug_units")

func _debug_units() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	await create_timer(0.3).timeout
	
	var vp = root.get_viewport()
	var camera = vp.get_camera_3d()
	var vp_size = vp.get_visible_rect().size
	print("VIEWPORT SIZE: ", vp_size)
	print("CAMERA POSITION: ", camera.global_position, " ROT: ", camera.global_rotation_degrees)
	
	var units = root.get_tree().get_nodes_in_group("Units")
	print("TOTAL UNITS IN GROUP: ", units.size())
	
	for i in range(units.size()):
		var u = units[i]
		var is_behind = camera.is_position_behind(u.global_position)
		var sp = camera.unproject_position(u.global_position)
		var in_view = (sp.x >= 0 and sp.x <= vp_size.x and sp.y >= 0 and sp.y <= vp_size.y)
		print("Unit %d [%s] team=%d pos=%s -> screen=%s is_behind=%s in_view=%s" % [
			i, u.get("unit_type"), u.get("team_id"), str(u.global_position), str(sp), str(is_behind), str(in_view)
		])
		
	quit(0)
