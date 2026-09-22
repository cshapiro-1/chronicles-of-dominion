extends SceneTree

func _init() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Frame 1: Master View
	for i in range(12):
		await process_frame
	var img_master = root.get_viewport().get_texture().get_image()
	img_master.save_png("C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/godot_live_render.png")
	print("Saved godot_live_render.png")

	var cam_rig = root.get_node_or_null("Main/CameraRig")
	if cam_rig:
		# Frame 2: Market Closeup
		cam_rig.target_position = Vector3(-28.0, 0, 28.0)
		cam_rig.global_position = Vector3(-28.0, 0, 28.0)
		cam_rig.target_zoom = 22.0
		var cam = cam_rig.get_node_or_null("Gimbal/PitchArm/Camera3D")
		if cam: cam.position.z = 22.0
		for i in range(10):
			await process_frame
		var img_market = root.get_viewport().get_texture().get_image()
		img_market.save_png("C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/market_focus_render.png")
		print("Saved market_focus_render.png")

		# Frame 3: Phalanx Soldiers Closeup
		cam_rig.target_position = Vector3(12.0, 0, 56.0)
		cam_rig.global_position = Vector3(12.0, 0, 56.0)
		cam_rig.target_zoom = 18.0
		if cam: cam.position.z = 18.0
		for i in range(10):
			await process_frame
		var img_soldiers = root.get_viewport().get_texture().get_image()
		img_soldiers.save_png("C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/scratch/soldiers_closeup.png")
		print("Saved soldiers_closeup.png")
	
	quit(0)
