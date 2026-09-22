extends SceneTree

func _init() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	var cam_rig = root.get_node_or_null("Main/CameraRig")
	if cam_rig:
		cam_rig.target_position = Vector3(-28.0, 0, 28.0)
		cam_rig.global_position = Vector3(-28.0, 0, 28.0)
		cam_rig.target_zoom = 24.0
		var cam = cam_rig.get_node_or_null("Gimbal/PitchArm/Camera3D")
		if cam:
			cam.position.z = 24.0
	
	# Wait 15 frames for camera and lighting to stabilize
	for i in range(15):
		await process_frame
	
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/market_closeup.png")
	print("Saved market_closeup.png successfully!")
	quit(0)
