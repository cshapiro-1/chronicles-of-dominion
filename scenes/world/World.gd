extends Node3D

func _ready() -> void:
	_setup_environment_and_lighting()
	_setup_flat_battlefield_ground()
	_build_strategic_cities_and_outposts()
	_setup_navigation()
	_build_field_armies_and_cohorts()

func _setup_environment_and_lighting() -> void:
	# Directional Sun Light matching reference mockup (warm low-angle morning sun)
	var sun = $DirectionalLight3D as DirectionalLight3D
	if sun:
		sun.rotation_degrees = Vector3(-42.0, 142.0, 0.0)
		sun.light_color = Color(1.0, 0.95, 0.86)
		sun.light_energy = 1.35
		sun.shadow_enabled = true
		sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
		sun.shadow_bias = 0.02
		sun.shadow_normal_bias = 2.0
		sun.shadow_blur = 1.2
		sun.shadow_opacity = 0.88

	# WorldEnvironment (Filmic tonemapping, SSAO, subtle desert haze)
	var env_node = $WorldEnvironment as WorldEnvironment
	if env_node and env_node.environment:
		var env = env_node.environment
		env.background_mode = Environment.BG_SKY
		
		var sky_mat = ProceduralSkyMaterial.new()
		sky_mat.sky_top_color = Color(0.25, 0.32, 0.42)
		sky_mat.sky_horizon_color = Color(0.82, 0.74, 0.62)
		sky_mat.sky_curve = 0.14
		sky_mat.ground_bottom_color = Color(0.18, 0.14, 0.10)
		sky_mat.ground_horizon_color = Color(0.58, 0.48, 0.36)
		
		var sky = Sky.new()
		sky.sky_material = sky_mat
		env.sky = sky
		
		env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		env.ambient_light_color = Color(0.74, 0.68, 0.58)
		env.ambient_light_energy = 0.85
		
		env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		env.tonemap_exposure = 1.08
		env.tonemap_white = 1.15
		
		# Screen Space Ambient Occlusion (SSAO)
		env.ssao_enabled = true
		env.ssao_radius = 2.8
		env.ssao_intensity = 3.2
		env.ssao_power = 1.6
		
		# Screen Space Indirect Lighting (SSIL)
		env.ssil_enabled = true
		env.ssil_radius = 5.0
		env.ssil_intensity = 1.1
		
		# Soft Volumetric Dust
		env.volumetric_fog_enabled = true
		env.volumetric_fog_density = 0.002
		env.volumetric_fog_albedo = Color(0.86, 0.78, 0.66)
		env.volumetric_fog_emission_energy = 0.7

func _setup_flat_battlefield_ground() -> void:
	var ground_mesh = get_node_or_null("NavigationRegion3D/Ground/MeshInstance3D") as MeshInstance3D
	if not ground_mesh:
		ground_mesh = get_node_or_null("Ground/MeshInstance3D") as MeshInstance3D
	if ground_mesh:
		ground_mesh.visible = true
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.82, 0.74, 0.58)
		mat.roughness = 0.92
		mat.specular = 0.12
		ground_mesh.material_override = mat
		ground_mesh.set_surface_override_material(0, mat)

func _build_strategic_cities_and_outposts() -> void:
	var parent_node = get_node_or_null("NavigationRegion3D")
	if not parent_node:
		parent_node = self
		
	var cities_root = Node3D.new()
	cities_root.name = "StrategicCities"
	parent_node.add_child(cities_root)

	# 1. Central Metropolis: Citadel of Ur-Kish (Around Ziggurat at 6.0, 0.0, 6.0)
	var ur_kish = Node3D.new()
	ur_kish.name = "City_UrKish"
	ur_kish.position = Vector3(6.0, 0.0, 6.0)
	
	# Outlying mudbrick civilian wards (Spaced cleanly away from Ziggurat perimeter)
	for ox in [-28.0, -24.0, 24.0, 28.0]:
		for oz in [-20.0, -14.0, 14.0, 20.0]:
			var house = MeshFactory.load_glb("res://assets/models/ancient_house_sculpted.glb")
			if house:
				house.scale = Vector3(0.35, 0.35, 0.35)
				house.position = Vector3(ox + randf_range(-0.5, 0.5), 0, oz + randf_range(-0.5, 0.5))
				ur_kish.add_child(house)

				
	# Floating Double-Headed Eagle Faction Banner
	var banner_eagle = _create_tactical_banner("res://assets/ui/banner_eagle_red.png", Vector3(0, 15.0, 0), 0.055)
	ur_kish.add_child(banner_eagle)
	cities_root.add_child(ur_kish)

	# 2. Southern Outpost
	var south_fort = Node3D.new()
	south_fort.name = "Outpost_South"
	south_fort.position = Vector3(36.0, 0.0, 38.0)
	var ramp = MeshFactory.load_glb("res://assets/models/citadel_rampart_modular.glb")
	if ramp:
		ramp.scale = Vector3(0.4, 0.4, 0.4)
		south_fort.add_child(ramp)
	var banner_sun = _create_tactical_banner("res://assets/ui/banner_sun_gold.png", Vector3(0, 7.0, 0), 0.04)
	south_fort.add_child(banner_sun)
	cities_root.add_child(south_fort)

	# 3. Northern Mountain Fortress
	var north_fort = Node3D.new()
	north_fort.name = "Outpost_North"
	north_fort.position = Vector3(-24.0, 0.0, -42.0)
	var ramp2 = MeshFactory.load_glb("res://assets/models/citadel_rampart_modular.glb")
	if ramp2:
		ramp2.scale = Vector3(0.4, 0.4, 0.4)
		north_fort.add_child(ramp2)
	var banner_blue = _create_tactical_banner("res://assets/ui/banner_crown_blue.png", Vector3(0, 7.5, 0), 0.04)
	north_fort.add_child(banner_blue)
	cities_root.add_child(north_fort)

func _setup_navigation() -> void:
	var nav_region = get_node_or_null("NavigationRegion3D") as NavigationRegion3D
	if nav_region and nav_region.navigation_mesh:
		var source_data = NavigationMeshSourceGeometryData3D.new()
		NavigationServer3D.parse_source_geometry_data(nav_region.navigation_mesh, source_data, nav_region)
		NavigationServer3D.bake_from_source_geometry_data(nav_region.navigation_mesh, source_data)
		# Trigger NavigationRegion3D update
		nav_region.navigation_mesh = nav_region.navigation_mesh

func register_placed_structure(structure_node: Node3D) -> void:
	var nav_region = get_node_or_null("NavigationRegion3D")
	if nav_region:
		nav_region.add_child(structure_node)
	else:
		add_child(structure_node)
		
	# Re-bake NavMesh with new structure obstacle
	_setup_navigation()

func notify_structure_built(_building: Node3D) -> void:
	_setup_navigation()

func notify_structure_destroyed(_building: Node3D) -> void:
	call_deferred("_setup_navigation")




func _build_field_armies_and_cohorts() -> void:
	var unit_scene = load("res://scenes/units/Unit.tscn")
	if not unit_scene: return
	
	# 1. Player Imperial Vanguard Center (Akkadian Spearmen)
	var vanguard = unit_scene.instantiate()
	vanguard.name = "Cohort_Spearmen_Vanguard"
	vanguard.unit_type = "spearman"
	vanguard.team_id = 0
	vanguard.position = Vector3(0.0, 0.0, 16.0)
	add_child(vanguard)
	
	# 2. Player Left Flank Spearmen
	var left_spear = unit_scene.instantiate()
	left_spear.name = "Cohort_Spearmen_Left"
	left_spear.unit_type = "spearman"
	left_spear.team_id = 0
	left_spear.position = Vector3(-10.0, 0.0, 18.0)
	add_child(left_spear)
	
	# 3. Player Right Flank Slingers
	var slingers = unit_scene.instantiate()
	slingers.name = "Cohort_Slingers"
	slingers.unit_type = "slinger"
	slingers.team_id = 0
	slingers.position = Vector3(10.0, 0.0, 18.0)
	add_child(slingers)
	
	# 4. Player War Chariot Squadron
	var chariots = unit_scene.instantiate()
	chariots.name = "Squadron_Chariots"
	chariots.unit_type = "chariot"
	chariots.team_id = 0
	chariots.position = Vector3(-18.0, 0.0, 24.0)
	add_child(chariots)
	
	# 5. Hostile Nomad Raider Incursion (Enemy advancing from south)
	var raiders = unit_scene.instantiate()
	raiders.name = "Enemy_Raiders_Alpha"
	raiders.unit_type = "raider"
	raiders.team_id = 1
	raiders.position = Vector3(0.0, 0.0, 42.0)
	add_child(raiders)

func _create_unit_regiment(type: String, rows: int, cols: int, unit_scale: float) -> Node3D:
	var root = Node3D.new()
	for r in range(rows):
		for c in range(cols):
			var soldier = MeshFactory.load_glb("res://assets/models/bronze_warrior_high.glb")
			if soldier:
				soldier.scale = Vector3(unit_scale, unit_scale, unit_scale)
				soldier.position = Vector3((c - cols*0.5) * 1.1, 0, (r - rows*0.5) * 1.1)
				root.add_child(soldier)
	return root

func _create_tactical_banner(tex_path: String, pos: Vector3, banner_scale: float = 0.04) -> Sprite3D:
	var s = Sprite3D.new()
	var tex = MeshFactory._load_tex(tex_path)
	if tex:
		s.texture = tex
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.pixel_size = banner_scale
	s.position = pos
	s.no_depth_test = false
	return s

func _apply_material_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		node.material_override = mat
	for child in node.get_children():
		_apply_material_recursive(child, mat)

