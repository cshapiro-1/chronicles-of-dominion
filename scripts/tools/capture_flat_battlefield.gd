extends SceneTree

func _init() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Run 40 frames for full Forward+ GPU rendering
	for i in range(40):
		await process_frame
		
	var hud = root.get_node_or_null("Main/UI/HUD")
	var cam_rig = root.get_node_or_null("Main/CameraRig")
	
	# Position camera to get a clear view of the battlefield, armies, and ziggurat on flat ground
	if cam_rig:
		cam_rig.global_position = Vector3(0.0, 0.0, 16.0)
		var cam = cam_rig.get_node_or_null("Gimbal/PitchArm/Camera3D")
		if cam:
			cam.position.z = 40.0
			
	# Select player units so their gold selection rings stand out clearly
	var player_units = []
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u) and u.get("team_id") == 0:
			player_units.append(u)
			
	if hud and not player_units.is_empty():
		hud._select_units(player_units)
		
	for i in range(15):
		await process_frame
		
	var vp = root.get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				var path = "C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/godot_flat_battlefield.png"
				img.save_png(path)
				print(">>> SAVED GODOT FLAT BATTLEFIELD RENDER TO: ", path)
				
	quit(0)
