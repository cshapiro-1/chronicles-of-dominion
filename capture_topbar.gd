extends SceneTree

func _init() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	print("--- Starting in-engine render capture ---")
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait for rendering pipeline and shaders to settle
	for i in range(25):
		await process_frame
	
	var vp = root.get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		var full_path = "C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/godot_live_render.png"
		img.save_png(full_path)
		print("Successfully saved live render: ", full_path, " (Size: ", img.get_size(), ")")
	else:
		print("ERROR: Viewport image was null!")
	quit(0)

