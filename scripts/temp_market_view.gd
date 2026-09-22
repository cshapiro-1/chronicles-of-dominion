extends SceneTree

func _init():
	change_scene_to_file("res://scenes/Main.tscn")

func _process(_delta):
	var cam_rig = root.get_node_or_null("Main/CameraRig")
	if cam_rig:
		cam_rig.target_position = Vector3(-24.0, 0.0, 28.0)
		cam_rig.global_position = Vector3(-24.0, 0.0, 28.0)
		cam_rig.target_zoom = 28.0
		var cam = cam_rig.get_node_or_null("Gimbal/PitchArm/Camera3D") as Camera3D
		if cam:
			cam.position.z = 28.0
	
	if Engine.get_process_frames() > 30:
		var img = root.get_viewport().get_texture().get_image()
		img.save_png("res://market_view_raw.png")
		quit()
