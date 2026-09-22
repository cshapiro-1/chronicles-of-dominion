@tool
extends SceneTree

func _init():
	var root = Node3D.new()
	var viewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	
	# Environment & Sun
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color('#1A1E24')
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color('#F5DEB3')
	env.ambient_light_energy = 0.45
	env_node.environment = env
	viewport.add_child(env_node)
	
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -35, 0)
	sun.light_color = Color('#FFF2D6')
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	viewport.add_child(sun)
	
	# Ground Plane
	var ground = MeshInstance3D.new()
	var gmesh = PlaneMesh.new()
	gmesh.size = Vector2(100, 100)
	var gmat = StandardMaterial3D.new()
	gmat.albedo_color = Color('#2A231D')
	gmat.roughness = 0.95
	ground.mesh = gmesh
	viewport.add_child(ground)
	
	# Load Asset
	var asset_scene = load('res://assets/generated/pending_approval/ziggurat_tier_01.tscn')
	if asset_scene:
		var asset_inst = asset_scene.instantiate()
		viewport.add_child(asset_inst)
	
	# Camera
	var cam = Camera3D.new()
	cam.position = Vector3(38, 30, 48)
	cam.look_at(Vector3(0, 10, 0))
	cam.fov = 42
	viewport.add_child(cam)
	
	# Add to tree
	get_root().add_child(root)
	
	# Force render frame
	await process_frame
	await process_frame
	
	var img = viewport.get_texture().get_image()
	if img:
		var save_dir = 'C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/'
		img.save_png(save_dir + 'ziggurat_tier_01_preview.png')
		print('Saved preview screenshot to ' + save_dir + 'ziggurat_tier_01_preview.png')
	else:
		print('Error: Could not retrieve viewport image')
	
	quit()
