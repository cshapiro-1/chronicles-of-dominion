extends Node

# Production PBR Materials
var mat_mudbrick: StandardMaterial3D
var mat_lapis: StandardMaterial3D
var mat_bronze: StandardMaterial3D
var mat_wood: StandardMaterial3D
var mat_frond: StandardMaterial3D
var mat_soil: StandardMaterial3D
var mat_crops: StandardMaterial3D
var mat_skin: StandardMaterial3D
var mat_linen: StandardMaterial3D
var mat_stone_step: StandardMaterial3D
var mat_processional: StandardMaterial3D
var mat_bronze_scale: StandardMaterial3D
var mat_shield_wicker: StandardMaterial3D
var mat_thatch: StandardMaterial3D
var mat_terracotta: StandardMaterial3D
var mat_bazaar_canopy: StandardMaterial3D

func _ready() -> void:
	_init_materials()

func _load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	var global_p = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_p):
		var img = Image.load_from_file(global_p)
		if img:
			return ImageTexture.create_from_image(img)
	return null

func _init_materials() -> void:
	if mat_mudbrick != null:
		return
		
	var tex_mud_alb = _load_tex("res://assets/textures/T_Mudbrick_Detailed_Albedo.png")
	if not tex_mud_alb: tex_mud_alb = _load_tex("res://assets/textures/T_Mudbrick_PBR.png")
	var tex_mud_nrm = _load_tex("res://assets/textures/T_Mudbrick_Detailed_Normal.png")
	var tex_mud_rgh = _load_tex("res://assets/textures/T_Mudbrick_Detailed_Roughness.png")

	var tex_lapis_alb = _load_tex("res://assets/textures/T_Lapis_Detailed_Albedo.png")
	if not tex_lapis_alb: tex_lapis_alb = _load_tex("res://assets/textures/T_LapisLazuli_PBR.png")
	var tex_lapis_nrm = _load_tex("res://assets/textures/T_Lapis_Detailed_Normal.png")
	var tex_lapis_rgh = _load_tex("res://assets/textures/T_Lapis_Detailed_Roughness.png")

	var tex_step_alb = _load_tex("res://assets/textures/T_Step_Stone_Detailed_Albedo.png")
	var tex_proc_alb = _load_tex("res://assets/textures/T_Limestone_Processional_Albedo.png")
	var tex_proc_nrm = _load_tex("res://assets/textures/T_Limestone_Processional_Normal.png")

	var tex_palm_bark_alb = _load_tex("res://assets/textures/T_Palm_Bark_Albedo.png")
	var tex_palm_bark_nrm = _load_tex("res://assets/textures/T_Palm_Bark_Normal.png")
	var tex_palm_frond_alb = _load_tex("res://assets/textures/T_Palm_Frond_Master.png")
	if not tex_palm_frond_alb: tex_palm_frond_alb = _load_tex("res://assets/textures/T_Palm_Frond.png")

	var tex_scale_alb = _load_tex("res://assets/textures/T_Bronze_Scale_Albedo.png")
	var tex_scale_nrm = _load_tex("res://assets/textures/T_Bronze_Scale_Normal.png")
	var tex_shield_alb = _load_tex("res://assets/textures/T_Wicker_Shield_Albedo.png")
	var tex_linen_alb = _load_tex("res://assets/textures/T_Linen_Tunic_Albedo.png")
	var tex_canopy = _load_tex("res://assets/textures/T_Bazaar_Striped_Canopy.png")

	# 1. Mudbrick Architecture
	mat_mudbrick = StandardMaterial3D.new()
	mat_mudbrick.albedo_color = Color(0.92, 0.80, 0.62, 1.0)
	if tex_mud_alb: mat_mudbrick.albedo_texture = tex_mud_alb
	if tex_mud_nrm:
		mat_mudbrick.normal_enabled = true
		mat_mudbrick.normal_texture = tex_mud_nrm
		mat_mudbrick.normal_scale = 0.25
	mat_mudbrick.roughness = 0.92
	mat_mudbrick.uv1_scale = Vector3(0.5, 0.5, 0.5)

	# 2. Glazed Lapis Lazuli Tiles
	mat_lapis = StandardMaterial3D.new()
	mat_lapis.albedo_color = Color(0.35, 0.55, 0.95, 1.0)
	if tex_lapis_alb: mat_lapis.albedo_texture = tex_lapis_alb
	if tex_lapis_nrm:
		mat_lapis.normal_enabled = true
		mat_lapis.normal_texture = tex_lapis_nrm
	mat_lapis.metallic = 0.45
	mat_lapis.roughness = 0.22
	mat_lapis.uv1_scale = Vector3(2, 2, 2)

	# 3. Bronze Trim & Gilding
	mat_bronze = StandardMaterial3D.new()
	mat_bronze.albedo_color = Color(0.96, 0.78, 0.32, 1.0)
	mat_bronze.metallic = 0.92
	mat_bronze.roughness = 0.28

	# 4. Cedar Wood & Palm Trunks
	mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.65, 0.48, 0.30, 1.0)
	if tex_palm_bark_alb: mat_wood.albedo_texture = tex_palm_bark_alb
	if tex_palm_bark_nrm:
		mat_wood.normal_enabled = true
		mat_wood.normal_texture = tex_palm_bark_nrm
	mat_wood.roughness = 0.82
	mat_wood.uv1_scale = Vector3(1, 4, 1)

	# 5. Palm Fronds Foliage (With subsurface translucency)
	mat_frond = StandardMaterial3D.new()
	mat_frond.albedo_color = Color(0.48, 0.82, 0.34, 1.0)
	if tex_palm_frond_alb: mat_frond.albedo_texture = tex_palm_frond_alb
	mat_frond.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_frond.roughness = 0.42
	mat_frond.backlight_enabled = true
	mat_frond.backlight = Color(0.35, 0.75, 0.25)

	# 6. Step Stone
	mat_stone_step = StandardMaterial3D.new()
	mat_stone_step.albedo_color = Color(0.88, 0.76, 0.58, 1.0)
	if tex_step_alb: mat_stone_step.albedo_texture = tex_step_alb
	mat_stone_step.roughness = 0.85
	mat_stone_step.uv1_scale = Vector3(2, 2, 2)

	# 7. Processional Avenue
	mat_processional = StandardMaterial3D.new()
	mat_processional.albedo_color = Color(0.92, 0.88, 0.78, 1.0)
	if tex_proc_alb: mat_processional.albedo_texture = tex_proc_alb
	if tex_proc_nrm:
		mat_processional.normal_enabled = true
		mat_processional.normal_texture = tex_proc_nrm
	mat_processional.roughness = 0.78
	mat_processional.uv1_scale = Vector3(2, 8, 2)

	# 8. Soldier Skin & Tunics
	mat_skin = StandardMaterial3D.new()
	mat_skin.albedo_color = Color(0.82, 0.60, 0.44, 1.0)
	mat_skin.roughness = 0.65

	mat_linen = StandardMaterial3D.new()
	mat_linen.albedo_color = Color(0.88, 0.82, 0.72, 1.0)
	if tex_linen_alb: mat_linen.albedo_texture = tex_linen_alb
	mat_linen.roughness = 0.85

	mat_shield_wicker = StandardMaterial3D.new()
	mat_shield_wicker.albedo_color = Color(0.70, 0.52, 0.32, 1.0)
	if tex_shield_alb: mat_shield_wicker.albedo_texture = tex_shield_alb
	mat_shield_wicker.roughness = 0.80

	# 9. Terracotta & Crops
	mat_terracotta = StandardMaterial3D.new()
	mat_terracotta.albedo_color = Color(0.85, 0.48, 0.28, 1.0)
	mat_terracotta.roughness = 0.75

	mat_crops = StandardMaterial3D.new()
	mat_crops.albedo_color = Color(0.92, 0.75, 0.20, 1.0)
	mat_crops.roughness = 0.45

	# 10. Bazaar Striped Canopy
	mat_bazaar_canopy = StandardMaterial3D.new()
	mat_bazaar_canopy.albedo_color = Color(0.92, 0.88, 0.76, 1.0)
	if tex_canopy: mat_bazaar_canopy.albedo_texture = tex_canopy
	mat_bazaar_canopy.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_bazaar_canopy.roughness = 0.85
	mat_bazaar_canopy.uv1_scale = Vector3(2, 1, 2)

func load_glb(path: String) -> Node3D:
	_init_materials()
	var global_p = ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(global_p):
		return null
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var err = doc.append_from_file(global_p, state)
	if err != OK:
		return null
	var scene = doc.generate_scene(state)
	if scene:
		_bind_materials_recursive(scene)
	return scene

func _bind_materials_recursive(node: Node) -> void:
	if node is MeshInstance3D:
		var mi = node as MeshInstance3D
		if mi.mesh:
			for surf_idx in range(mi.mesh.get_surface_count()):
				var mat = mi.mesh.surface_get_material(surf_idx)
				if mat:
					var mname = mat.resource_name
					if mname == "M_PalmBark" or mname == "M_CedarBeams" or mname == "M_CedarGate" or mname == "M_TimberStall":
						mi.set_surface_override_material(surf_idx, mat_wood)
					elif mname == "M_PalmFrond":
						mi.set_surface_override_material(surf_idx, mat_frond)
					elif mname == "M_Dates":
						mi.set_surface_override_material(surf_idx, mat_crops)
					elif mname == "M_DrapedCanopy":
						mi.set_surface_override_material(surf_idx, mat_bazaar_canopy)
					elif mname == "M_TerracottaAmphora":
						mi.set_surface_override_material(surf_idx, mat_terracotta)
					elif mname == "M_MudbrickAdobe" or mname == "M_ZigguratMudbrick" or mname == "M_RampartStone":
						mi.set_surface_override_material(surf_idx, mat_mudbrick)
					elif mname == "M_LapisTrim" or mname == "M_ZigguratLapisFrieze" or mname == "M_GateLapisTrim":
						mi.set_surface_override_material(surf_idx, mat_lapis)
					elif mname == "M_ZigguratGoldBronze" or mname == "M_WarriorBronze":
						mi.set_surface_override_material(surf_idx, mat_bronze)
					elif mname == "M_ZigguratLimestone":
						mi.set_surface_override_material(surf_idx, mat_stone_step)
					elif mname == "M_WarriorSkin":
						mi.set_surface_override_material(surf_idx, mat_skin)
					elif mname == "M_WarriorTunic":
						mi.set_surface_override_material(surf_idx, mat_linen)
					elif mname == "M_WarriorShieldWicker":
						mi.set_surface_override_material(surf_idx, mat_shield_wicker)
	for child in node.get_children():
		_bind_materials_recursive(child)

func apply_pbr_to_tree(node: Node) -> void:
	_init_materials()
	_bind_materials_recursive(node)

func add_box(st: SurfaceTool, center: Vector3, size: Vector3, uv_rep: Vector2 = Vector2.ONE) -> void:
	var hx = size.x * 0.5; var hy = size.y * 0.5; var hz = size.z * 0.5
	var cx = center.x; var cy = center.y; var cz = center.z
	var v0 = Vector3(cx - hx, cy - hy, cz + hz)
	var v1 = Vector3(cx + hx, cy - hy, cz + hz)
	var v2 = Vector3(cx + hx, cy + hy, cz + hz)
	var v3 = Vector3(cx - hx, cy + hy, cz + hz)
	var v4 = Vector3(cx - hx, cy - hy, cz - hz)
	var v5 = Vector3(cx + hx, cy - hy, cz - hz)
	var v6 = Vector3(cx + hx, cy + hy, cz - hz)
	var v7 = Vector3(cx - hx, cy + hy, cz - hz)
	add_quad(st, v0, v1, v2, v3, Vector3.FORWARD, uv_rep)
	add_quad(st, v5, v4, v7, v6, Vector3.BACK, uv_rep)
	add_quad(st, v4, v0, v3, v7, Vector3.LEFT, uv_rep)
	add_quad(st, v1, v5, v6, v2, Vector3.RIGHT, uv_rep)
	add_quad(st, v3, v2, v6, v7, Vector3.UP, uv_rep)
	add_quad(st, v4, v5, v1, v0, Vector3.DOWN, uv_rep)

func add_frustum(st: SurfaceTool, cx: float, y_bot: float, y_top: float, cz: float, sx_bot: float, sz_bot: float, sx_top: float, sz_top: float, uv_rep: Vector2 = Vector2.ONE) -> void:
	var hxb = sx_bot * 0.5; var hzb = sz_bot * 0.5
	var hxt = sx_top * 0.5; var hzt = sz_top * 0.5
	var v0 = Vector3(cx - hxb, y_bot, cz + hzb)
	var v1 = Vector3(cx + hxb, y_bot, cz + hzb)
	var v2 = Vector3(cx + hxt, y_top, cz + hzt)
	var v3 = Vector3(cx - hxt, y_top, cz + hzt)
	var v4 = Vector3(cx - hxb, y_bot, cz - hzb)
	var v5 = Vector3(cx + hxb, y_bot, cz - hzb)
	var v6 = Vector3(cx + hxt, y_top, cz - hzt)
	var v7 = Vector3(cx - hxt, y_top, cz - hzt)
	add_quad(st, v0, v1, v2, v3, Vector3.FORWARD, uv_rep)
	add_quad(st, v5, v4, v7, v6, Vector3.BACK, uv_rep)
	add_quad(st, v4, v0, v3, v7, Vector3.LEFT, uv_rep)
	add_quad(st, v1, v5, v6, v2, Vector3.RIGHT, uv_rep)
	add_quad(st, v3, v2, v6, v7, Vector3.UP, uv_rep)
	add_quad(st, v4, v5, v1, v0, Vector3.DOWN, uv_rep)

func add_quad(st: SurfaceTool, v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, norm: Vector3, uv_rep: Vector2) -> void:
	st.set_normal(norm)
	st.set_uv(Vector2(0, 0)); st.add_vertex(v0)
	st.set_uv(Vector2(uv_rep.x, 0)); st.add_vertex(v1)
	st.set_uv(Vector2(uv_rep.x, uv_rep.y)); st.add_vertex(v2)
	st.set_uv(Vector2(0, 0)); st.add_vertex(v0)
	st.set_uv(Vector2(uv_rep.x, uv_rep.y)); st.add_vertex(v2)
	st.set_uv(Vector2(0, uv_rep.y)); st.add_vertex(v3)

func create_chariot_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()
	var st_w = SurfaceTool.new()
	st_w.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_w.set_material(mat_wood)
	add_box(st_w, Vector3(0, 0.5, 0), Vector3(1.4, 0.1, 1.6))
	add_box(st_w, Vector3(0, 0.55, 1.8), Vector3(0.12, 0.12, 2.2))
	add_box(st_w, Vector3(0, 0.8, 2.8), Vector3(1.8, 0.12, 0.12))
	st_w.generate_normals()
	st_w.commit(mesh)

	var st_b = SurfaceTool.new()
	st_b.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_b.set_material(mat_bronze)
	add_box(st_b, Vector3(0, 1.0, 0.75), Vector3(1.4, 0.9, 0.12))
	add_box(st_b, Vector3(-0.68, 0.9, 0.1), Vector3(0.1, 0.7, 1.3))
	add_box(st_b, Vector3(0.68, 0.9, 0.1), Vector3(0.1, 0.7, 1.3))
	add_box(st_b, Vector3(-0.85, 0.55, 0), Vector3(0.1, 1.1, 1.1))
	add_box(st_b, Vector3(0.85, 0.55, 0), Vector3(0.1, 1.1, 1.1))
	add_box(st_b, Vector3(0.25, 1.65, 0.1), Vector3(0.3, 0.3, 0.3))
	add_box(st_b, Vector3(-0.25, 1.65, 0.1), Vector3(0.3, 0.3, 0.3))
	st_b.generate_normals()
	st_b.commit(mesh)
	return mesh
