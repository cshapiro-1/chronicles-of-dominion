@tool
extends SceneTree

func _init():
	print('Building Ziggurat Tier 01 asset...')
	var dir = DirAccess.open('res://')
	if not dir.dir_exists('res://assets/generated/pending_approval'):
		dir.make_dir_recursive('res://assets/generated/pending_approval')
	
	var root = Node3D.new()
	root.name = 'ZigguratTier01'
	
	# Materials
	var mat_mudbrick_base = StandardMaterial3D.new()
	mat_mudbrick_base.albedo_color = Color('#D8BA8C')
	mat_mudbrick_base.roughness = 0.88
	if ResourceLoader.exists('res://assets/textures/T_Mudbrick_PBR.png'):
		mat_mudbrick_base.albedo_texture = load('res://assets/textures/T_Mudbrick_PBR.png')
		mat_mudbrick_base.uv1_scale = Vector3(6, 6, 6)
	
	var mat_mudbrick_mid = StandardMaterial3D.new()
	mat_mudbrick_mid.albedo_color = Color('#CCA472')
	mat_mudbrick_mid.roughness = 0.85
	if ResourceLoader.exists('res://assets/textures/T_Mudbrick_PBR.png'):
		mat_mudbrick_mid.albedo_texture = load('res://assets/textures/T_Mudbrick_PBR.png')
		mat_mudbrick_mid.uv1_scale = Vector3(4, 4, 4)

	var mat_mudbrick_top = StandardMaterial3D.new()
	mat_mudbrick_top.albedo_color = Color('#BF9560')
	mat_mudbrick_top.roughness = 0.82
	if ResourceLoader.exists('res://assets/textures/T_Mudbrick_PBR.png'):
		mat_mudbrick_top.albedo_texture = load('res://assets/textures/T_Mudbrick_PBR.png')
		mat_mudbrick_top.uv1_scale = Vector3(3, 3, 3)

	var mat_lapis = StandardMaterial3D.new()
	mat_lapis.albedo_color = Color('#1B3D7A')
	mat_lapis.metallic = 0.35
	mat_lapis.roughness = 0.28
	if ResourceLoader.exists('res://assets/textures/T_LapisLazuli_PBR.png'):
		mat_lapis.albedo_texture = load('res://assets/textures/T_LapisLazuli_PBR.png')
		mat_lapis.uv1_scale = Vector3(2, 2, 2)

	var mat_gold = StandardMaterial3D.new()
	mat_gold.albedo_color = Color('#D4AF37')
	mat_gold.metallic = 0.85
	mat_gold.roughness = 0.32

	var mat_dark_cedar = StandardMaterial3D.new()
	mat_dark_cedar.albedo_color = Color('#3B2616')
	mat_dark_cedar.roughness = 0.75

	var mat_stair = StandardMaterial3D.new()
	mat_stair.albedo_color = Color('#BFA175')
	mat_stair.roughness = 0.9

	# --- Tier 1 (Base: 36 x 32 x 6) ---
	var t1 = MeshInstance3D.new()
	t1.name = 'Tier1_Base'
	var t1_box = BoxMesh.new()
	t1_box.size = Vector3(36, 6, 32)
	t1_box.material = mat_mudbrick_base
	t1.mesh = t1_box
	t1.position = Vector3(0, 3, 0)
	root.add_child(t1)
	t1.owner = root

	# Tier 1 Buttresses (Front & Back & Sides)
	var buttress_mesh = BoxMesh.new()
	buttress_mesh.size = Vector3(1.2, 6.1, 0.7)
	buttress_mesh.material = mat_mudbrick_base

	for i in range(-5, 6):
		if i == 0 or i == -1 or i == 1: continue # leave center for stairway
		var b_f = MeshInstance3D.new()
		b_f.name = 'Buttress_T1_F_' + str(i)
		b_f.mesh = buttress_mesh
		b_f.position = Vector3(i * 3.2, 3, 16.2)
		root.add_child(b_f)
		b_f.owner = root

		var b_b = MeshInstance3D.new()
		b_b.name = 'Buttress_T1_B_' + str(i)
		b_b.mesh = buttress_mesh
		b_b.position = Vector3(i * 3.2, 3, -16.2)
		root.add_child(b_b)
		b_b.owner = root

	var buttress_side_mesh = BoxMesh.new()
	buttress_side_mesh.size = Vector3(0.7, 6.1, 1.2)
	buttress_side_mesh.material = mat_mudbrick_base

	for i in range(-4, 5):
		var b_l = MeshInstance3D.new()
		b_l.name = 'Buttress_T1_L_' + str(i)
		b_l.mesh = buttress_side_mesh
		b_l.position = Vector3(-18.2, 3, i * 3.2)
		root.add_child(b_l)
		b_l.owner = root

		var b_r = MeshInstance3D.new()
		b_r.name = 'Buttress_T1_R_' + str(i)
		b_r.mesh = buttress_side_mesh
		b_r.position = Vector3(18.2, 3, i * 3.2)
		root.add_child(b_r)
		b_r.owner = root

	# --- Tier 2 (Mid: 24 x 22 x 4.5) ---
	var t2 = MeshInstance3D.new()
	t2.name = 'Tier2_Mid'
	var t2_box = BoxMesh.new()
	t2_box.size = Vector3(24, 4.5, 22)
	t2_box.material = mat_mudbrick_mid
	t2.mesh = t2_box
	t2.position = Vector3(0, 6 + 2.25, 0) # y = 8.25
	root.add_child(t2)
	t2.owner = root

	# Tier 2 Buttresses
	var b2_mesh = BoxMesh.new()
	b2_mesh.size = Vector3(1.0, 4.6, 0.6)
	b2_mesh.material = mat_mudbrick_mid
	for i in range(-3, 4):
		if i == 0: continue
		var b2_f = MeshInstance3D.new()
		b2_f.name = 'Buttress_T2_F_' + str(i)
		b2_f.mesh = b2_mesh
		b2_f.position = Vector3(i * 3.2, 8.25, 11.15)
		root.add_child(b2_f)
		b2_f.owner = root

		var b2_b = MeshInstance3D.new()
		b2_b.name = 'Buttress_T2_B_' + str(i)
		b2_b.mesh = b2_mesh
		b2_b.position = Vector3(i * 3.2, 8.25, -11.15)
		root.add_child(b2_b)
		b2_b.owner = root

	# --- Tier 3 (Upper: 15 x 14 x 3.5) ---
	var t3 = MeshInstance3D.new()
	t3.name = 'Tier3_Upper'
	var t3_box = BoxMesh.new()
	t3_box.size = Vector3(15, 3.5, 14)
	t3_box.material = mat_mudbrick_top
	t3.mesh = t3_box
	t3.position = Vector3(0, 10.5 + 1.75, 0) # y = 12.25
	root.add_child(t3)
	t3.owner = root

	# Tier 3 Decorative Cornice Ribbon
	var cornice = MeshInstance3D.new()
	cornice.name = 'Tier3_Cornice'
	var c_mesh = BoxMesh.new()
	c_mesh.size = Vector3(15.4, 0.4, 14.4)
	c_mesh.material = mat_gold
	cornice.mesh = c_mesh
	cornice.position = Vector3(0, 14.1, 0)
	root.add_child(cornice)
	cornice.owner = root

	# --- Summit Shrine / High Temple (Cella: 9 x 7 x 4.2) ---
	var shrine = MeshInstance3D.new()
	shrine.name = 'Summit_Shrine_Cella'
	var shrine_box = BoxMesh.new()
	shrine_box.size = Vector3(9, 4.2, 7)
	shrine_box.material = mat_lapis
	shrine.mesh = shrine_box
	shrine.position = Vector3(0, 14 + 2.1, -1.0) # y = 16.1, offset slightly back
	root.add_child(shrine)
	shrine.owner = root

	# Shrine Parapet / Crenellations
	var shrine_roof = MeshInstance3D.new()
	shrine_roof.name = 'Shrine_Crenellated_Roof'
	var sr_mesh = BoxMesh.new()
	sr_mesh.size = Vector3(9.4, 0.5, 7.4)
	sr_mesh.material = mat_gold
	shrine_roof.mesh = sr_mesh
	shrine_roof.position = Vector3(0, 18.3, -1.0)
	root.add_child(shrine_roof)
	shrine_roof.owner = root

	# Shrine Portal / Entrance Arch
	var portal_frame = MeshInstance3D.new()
	portal_frame.name = 'Shrine_Portal_Frame'
	var pf_mesh = BoxMesh.new()
	pf_mesh.size = Vector3(3.2, 3.2, 0.5)
	pf_mesh.material = mat_gold
	portal_frame.mesh = pf_mesh
	portal_frame.position = Vector3(0, 15.6, 2.6)
	root.add_child(portal_frame)
	portal_frame.owner = root

	var portal_door = MeshInstance3D.new()
	portal_door.name = 'Shrine_Portal_Interior'
	var pd_mesh = BoxMesh.new()
	pd_mesh.size = Vector3(2.2, 2.8, 0.6)
	pd_mesh.material = mat_dark_cedar
	portal_door.mesh = pd_mesh
	portal_door.position = Vector3(0, 15.4, 2.65)
	root.add_child(portal_door)
	portal_door.owner = root

	# Golden Temple Spire / Standard
	var spire = MeshInstance3D.new()
	spire.name = 'Temple_Golden_Emblem'
	var spire_mesh = CylinderMesh.new()
	spire_mesh.top_radius = 0.05
	spire_mesh.bottom_radius = 0.35
	spire_mesh.height = 2.4
	spire_mesh.material = mat_gold
	spire.mesh = spire_mesh
	spire.position = Vector3(0, 19.6, -1.0)
	root.add_child(spire)
	spire.owner = root

	# --- Monumental Stairways ---
	# 1. Central Axial Staircase (Ground to Tier 1 Landing, then Tier 2 to Tier 3)
	var stair_central_ramp1 = MeshInstance3D.new()
	stair_central_ramp1.name = 'Stair_Central_Lower'
	var sc1_mesh = BoxMesh.new()
	sc1_mesh.size = Vector3(4.5, 0.5, 16.0)
	sc1_mesh.material = mat_stair
	stair_central_ramp1.mesh = sc1_mesh
	stair_central_ramp1.position = Vector3(0, 3.0, 23.0)
	stair_central_ramp1.rotation_degrees = Vector3(21.0, 0, 0)
	root.add_child(stair_central_ramp1)
	stair_central_ramp1.owner = root

	var stair_central_ramp2 = MeshInstance3D.new()
	stair_central_ramp2.name = 'Stair_Central_Upper'
	var sc2_mesh = BoxMesh.new()
	sc2_mesh.size = Vector3(3.6, 0.4, 18.0)
	sc2_mesh.material = mat_stair
	stair_central_ramp2.mesh = sc2_mesh
	stair_central_ramp2.position = Vector3(0, 10.0, 11.5)
	stair_central_ramp2.rotation_degrees = Vector3(25.0, 0, 0)
	root.add_child(stair_central_ramp2)
	stair_central_ramp2.owner = root

	# 2. Flanking Wing Staircases (Hugging Tier 1 Front)
	var stair_left_wing = MeshInstance3D.new()
	stair_left_wing.name = 'Stair_Left_Wing'
	var slw_mesh = BoxMesh.new()
	slw_mesh.size = Vector3(14.0, 0.4, 3.2)
	slw_mesh.material = mat_stair
	stair_left_wing.mesh = slw_mesh
	stair_left_wing.position = Vector3(-8.5, 3.0, 17.6)
	stair_left_wing.rotation_degrees = Vector3(0, 0, -22.0)
	root.add_child(stair_left_wing)
	stair_left_wing.owner = root

	var stair_right_wing = MeshInstance3D.new()
	stair_right_wing.name = 'Stair_Right_Wing'
	var srw_mesh = BoxMesh.new()
	srw_mesh.size = Vector3(14.0, 0.4, 3.2)
	srw_mesh.material = mat_stair
	stair_right_wing.mesh = srw_mesh
	stair_right_wing.position = Vector3(8.5, 3.0, 17.6)
	stair_right_wing.rotation_degrees = Vector3(0, 0, 22.0)
	root.add_child(stair_right_wing)
	stair_right_wing.owner = root

	# Central Portal Arch / Gate at Tier 1 landing
	var arch_t1 = MeshInstance3D.new()
	arch_t1.name = 'Gate_Tier1_Arch'
	var at1_mesh = BoxMesh.new()
	at1_mesh.size = Vector3(4.8, 3.5, 1.2)
	at1_mesh.material = mat_gold
	arch_t1.mesh = at1_mesh
	arch_t1.position = Vector3(0, 7.75, 16.0)
	root.add_child(arch_t1)
	arch_t1.owner = root

	# Flanking Braziers at Shrine Entrance
	for side in [-2.5, 2.5]:
		var brazier_base = MeshInstance3D.new()
		brazier_base.name = 'Shrine_Brazier_' + ('L' if side < 0 else 'R')
		var bb_mesh = CylinderMesh.new()
		bb_mesh.top_radius = 0.4
		bb_mesh.bottom_radius = 0.5
		bb_mesh.height = 1.0
		bb_mesh.material = mat_gold
		brazier_base.mesh = bb_mesh
		brazier_base.position = Vector3(side, 14.5, 4.2)
		root.add_child(brazier_base)
		brazier_base.owner = root

	# Save PackedScene
	var scene = PackedScene.new()
	var result = scene.pack(root)
	if result == OK:
		var save_path = 'res://assets/generated/pending_approval/ziggurat_tier_01.tscn'
		var err = ResourceSaver.save(scene, save_path)
		if err == OK:
			print('SUCCESS: Saved ' + save_path)
		else:
			print('ERROR: Failed to save scene: ' + str(err))
	else:
		print('ERROR: Failed to pack scene: ' + str(result))
	
	quit()
