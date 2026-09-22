extends SceneTree

func _init() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait for physics & rendering to initialize
	for i in range(20):
		await process_frame
		
	var hud = root.get_node_or_null("Main/UI/HUD")
	var cam_rig = root.get_node_or_null("Main/CameraRig")
	
	# Select player units so their selection rings are visible
	var player_units = []
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u) and u.get("team_id") == 0:
			player_units.append(u)
			
	if hud and not player_units.is_empty():
		hud._select_units(player_units)
		
	# Frame camera closely over the field armies
	if cam_rig:
		cam_rig.global_position = Vector3(0.0, 0.0, 20.0)
		var cam = cam_rig.get_node_or_null("Gimbal/PitchArm/Camera3D")
		if cam:
			cam.position.z = 32.0
			
	for i in range(15):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/godot_tactical_closeup.png")
	print("Captured tactical closeup to godot_tactical_closeup.png")
	quit(0)
