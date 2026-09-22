extends SceneTree

func _init() -> void:
	call_deferred("_run_capture")

func _run_capture() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait 10 frames
	for i in range(15):
		await process_frame
	
	# Trigger Citadel Conquest Destruction
	var citadel = root.get_node_or_null("Main/World/EnemyCitadel")
	if citadel and citadel.has_method("take_damage"):
		citadel.take_damage(2500.0)
		print("Inflicted 2500 damage on Enemy Citadel -> Victory triggered.")
	
	for i in range(10):
		await process_frame
	
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/conquest_victory_render.png")
	print("Captured viewport to conquest_victory_render.png")
	quit(0)
