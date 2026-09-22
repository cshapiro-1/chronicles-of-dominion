extends SceneTree

func _init() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait 5 frames for rendering pipeline to stabilize
	for i in range(10):
		await process_frame
	
	var cam_rig = root.get_node_or_null("Main/CameraRig")
	if cam_rig:
		print("CameraRig found at global_pos: ", cam_rig.global_position)
		var cam = cam_rig.get_node_or_null("Gimbal/PitchArm/Camera3D")
		if cam:
			print("Camera3D global_pos: ", cam.global_position, " current: ", cam.current)
	
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/godot_live_render.png")
	print("Captured viewport to godot_live_render.png")
	quit(0)
