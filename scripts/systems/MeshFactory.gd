extends Node

var mat_mudbrick: StandardMaterial3D
var mat_lapis: StandardMaterial3D
var mat_bronze: StandardMaterial3D
var mat_wood: StandardMaterial3D
var mat_frond: StandardMaterial3D
var mat_soil: StandardMaterial3D
var mat_crops: StandardMaterial3D
var mat_skin: StandardMaterial3D
var mat_linen: StandardMaterial3D

func _ready() -> void:
	_init_materials()

func _load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	# Direct fallback via Image
	var global_p = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_p):
		var img = Image.load_from_file(global_p)
		if img:
			return ImageTexture.create_from_image(img)
	return null

func _init_materials() -> void:
	if mat_mudbrick != null:
		return
		
	var tex_mud = _load_tex("res://assets/textures/T_Mudbrick_PBR.png")
	var tex_lapis = _load_tex("res://assets/textures/T_LapisLazuli_PBR.png")
	var tex_bronze = _load_tex("res://assets/textures/T_Bronze_PBR.png")
	var tex_wood = _load_tex("res://assets/textures/T_Wood_PBR.png")
	var tex_frond = _load_tex("res://assets/textures/T_Palm_Frond.png")

	mat_mudbrick = StandardMaterial3D.new()
	mat_mudbrick.albedo_color = Color(0.85, 0.72, 0.55)
	if tex_mud: mat_mudbrick.albedo_texture = tex_mud
	mat_mudbrick.uv1_scale = Vector3(4, 4, 4)
	mat_mudbrick.roughness = 0.9

	mat_lapis = StandardMaterial3D.new()
	mat_lapis.albedo_color = Color(0.2, 0.45, 0.95)
	if tex_lapis: mat_lapis.albedo_texture = tex_lapis
	mat_lapis.uv1_scale = Vector3(2, 2, 2)
	mat_lapis.metallic = 0.35
	mat_lapis.roughness = 0.25

	mat_bronze = StandardMaterial3D.new()
	mat_bronze.albedo_color = Color(0.95, 0.75, 0.35)
	if tex_bronze: mat_bronze.albedo_texture = tex_bronze
	mat_bronze.metallic = 0.8
	mat_bronze.roughness = 0.35

	mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.55, 0.38, 0.22)
	if tex_wood: mat_wood.albedo_texture = tex_wood
	mat_wood.roughness = 0.85

	mat_frond = StandardMaterial3D.new()
	mat_frond.albedo_color = Color(0.35, 0.75, 0.25)
	if tex_frond: mat_frond.albedo_texture = tex_frond
	mat_frond.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat_frond.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_frond.roughness = 0.6

	mat_soil = StandardMaterial3D.new()
	mat_soil.albedo_color = Color(0.22, 0.16, 0.1)
	mat_soil.roughness = 0.95

	mat_crops = StandardMaterial3D.new()
	mat_crops.albedo_color = Color(0.88, 0.78, 0.3)
	mat_crops.roughness = 0.75

	mat_skin = StandardMaterial3D.new()
	mat_skin.albedo_color = Color(0.78, 0.58, 0.45)
	mat_skin.roughness = 0.8

	mat_linen = StandardMaterial3D.new()
	mat_linen.albedo_color = Color(0.9, 0.85, 0.75)
	mat_linen.roughness = 0.9

func _add_box(st: SurfaceTool, center: Vector3, size: Vector3, uv_rep: Vector2 = Vector2.ONE) -> void:
	var h = size * 0.5
	var c = center
	var v0 = c + Vector3(-h.x, -h.y,  h.z)
	var v1 = c + Vector3( h.x, -h.y,  h.z)
	var v2 = c + Vector3( h.x,  h.y,  h.z)
	var v3 = c + Vector3(-h.x,  h.y,  h.z)
	var v4 = c + Vector3(-h.x, -h.y, -h.z)
	var v5 = c + Vector3( h.x, -h.y, -h.z)
	var v6 = c + Vector3( h.x,  h.y, -h.z)
	var v7 = c + Vector3(-h.x,  h.y, -h.z)
	_add_quad(st, v0, v1, v2, v3, Vector3.FORWARD, uv_rep)
	_add_quad(st, v5, v4, v7, v6, Vector3.BACK, uv_rep)
	_add_quad(st, v4, v0, v3, v7, Vector3.LEFT, uv_rep)
	_add_quad(st, v1, v5, v6, v2, Vector3.RIGHT, uv_rep)
	_add_quad(st, v3, v2, v6, v7, Vector3.UP, uv_rep)
	_add_quad(st, v4, v5, v1, v0, Vector3.DOWN, uv_rep)

func _add_frustum(st: SurfaceTool, cx: float, y_bot: float, y_top: float, cz: float, sx_bot: float, sz_bot: float, sx_top: float, sz_top: float, uv_rep: Vector2 = Vector2.ONE) -> void:
	var hxb = sx_bot * 0.5
	var hzb = sz_bot * 0.5
	var hxt = sx_top * 0.5
	var hzt = sz_top * 0.5
	var v0 = Vector3(cx - hxb, y_bot, cz + hzb)
	var v1 = Vector3(cx + hxb, y_bot, cz + hzb)
	var v2 = Vector3(cx + hxt, y_top, cz + hzt)
	var v3 = Vector3(cx - hxt, y_top, cz + hzt)
	var v4 = Vector3(cx - hxb, y_bot, cz - hzb)
	var v5 = Vector3(cx + hxb, y_bot, cz - hzb)
	var v6 = Vector3(cx + hxt, y_top, cz - hzt)
	var v7 = Vector3(cx - hxt, y_top, cz - hzt)
	_add_quad(st, v0, v1, v2, v3, Vector3.FORWARD, uv_rep)
	_add_quad(st, v5, v4, v7, v6, Vector3.BACK, uv_rep)
	_add_quad(st, v4, v0, v3, v7, Vector3.LEFT, uv_rep)
	_add_quad(st, v1, v5, v6, v2, Vector3.RIGHT, uv_rep)
	_add_quad(st, v3, v2, v6, v7, Vector3.UP, uv_rep)
	_add_quad(st, v4, v5, v1, v0, Vector3.DOWN, uv_rep)

func _add_quad(st: SurfaceTool, v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, norm: Vector3, uv_rep: Vector2) -> void:
	st.set_normal(norm)
	st.set_uv(Vector2(0, 0)); st.add_vertex(v0)
	st.set_uv(Vector2(uv_rep.x, 0)); st.add_vertex(v1)
	st.set_uv(Vector2(uv_rep.x, uv_rep.y)); st.add_vertex(v2)
	st.set_uv(Vector2(0, 0)); st.add_vertex(v0)
	st.set_uv(Vector2(uv_rep.x, uv_rep.y)); st.add_vertex(v2)
	st.set_uv(Vector2(0, uv_rep.y)); st.add_vertex(v3)

func create_ziggurat_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_mudbrick)

	# Broad Foundation Plaza: 32m x 32m x 1m
	_add_box(st, Vector3(0, 0.5, 0), Vector3(32, 1.0, 32), Vector2(8, 8))

	# Tier 1 with sloped batter: Base 26m, Top 22m, Height 1m to 5m
	_add_frustum(st, 0, 1.0, 5.0, 0, 26.0, 26.0, 22.0, 22.0, Vector2(6, 2))
	for i in range(1, 6):
		var x = -11.0 + i * (22.0 / 6)
		_add_box(st, Vector3(x, 3.0, 11.4), Vector3(1.0, 4.0, 0.8), Vector2(1, 2))
		_add_box(st, Vector3(x, 3.0, -11.4), Vector3(1.0, 4.0, 0.8), Vector2(1, 2))
		_add_box(st, Vector3(-11.4, 3.0, x), Vector3(0.8, 4.0, 1.0), Vector2(1, 2))
		_add_box(st, Vector3(11.4, 3.0, x), Vector3(0.8, 4.0, 1.0), Vector2(1, 2))

	# Tier 2: Base 17m, Top 14m, Height 5m to 8.2m
	_add_frustum(st, 0, 5.0, 8.2, 0, 17.0, 17.0, 14.0, 14.0, Vector2(5, 2))
	for i in range(1, 4):
		var x = -7.0 + i * (14.0 / 4)
		_add_box(st, Vector3(x, 6.6, 7.3), Vector3(0.8, 3.2, 0.6), Vector2(1, 2))
		_add_box(st, Vector3(x, 6.6, -7.3), Vector3(0.8, 3.2, 0.6), Vector2(1, 2))
		_add_box(st, Vector3(-7.3, 6.6, x), Vector3(0.6, 3.2, 0.8), Vector2(1, 2))
		_add_box(st, Vector3(7.3, 6.6, x), Vector3(0.6, 3.2, 0.8), Vector2(1, 2))

	# Tier 3: Base 10.5m, Top 8.5m, Height 8.2m to 10.8m
	_add_frustum(st, 0, 8.2, 10.8, 0, 10.5, 10.5, 8.5, 8.5, Vector2(4, 1))

	# Triple Staircases
	var steps = 18
	for s in range(steps):
		var t = s / float(steps)
		var y = 1.0 + t * 4.0
		var z = 21.0 - t * 9.5
		_add_box(st, Vector3(0, y + 0.15, z), Vector3(3.8, 0.35, 0.8), Vector2(1, 1))
		_add_box(st, Vector3(-2.1, y + 0.4, z), Vector3(0.4, 0.7, 0.8))
		_add_box(st, Vector3(2.1, y + 0.4, z), Vector3(0.4, 0.7, 0.8))

	for s in range(14):
		var t = s / 14.0
		var y = 1.0 + t * 4.0
		var x = -11.5 + t * 8.0
		_add_box(st, Vector3(x, y + 0.15, 11.8), Vector3(0.85, 0.35, 2.0), Vector2(1, 1))
		var x_r = 11.5 - t * 8.0
		_add_box(st, Vector3(x_r, y + 0.15, 11.8), Vector3(0.85, 0.35, 2.0), Vector2(1, 1))

	for s in range(16):
		var t = s / 16.0
		var y = 5.0 + t * 5.8
		var z = 11.5 - t * 8.0
		_add_box(st, Vector3(0, y + 0.2, z), Vector3(2.6, 0.4, 0.75), Vector2(1, 1))

	st.generate_normals()
	st.generate_tangents()
	st.commit(mesh)

	var st_lapis = SurfaceTool.new()
	st_lapis.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_lapis.set_material(mat_lapis)
	_add_box(st_lapis, Vector3(0, 12.4, 0), Vector3(5.4, 3.2, 5.4), Vector2(2, 2))
	st_lapis.generate_normals()
	st_lapis.generate_tangents()
	st_lapis.commit(mesh)

	var st_gold = SurfaceTool.new()
	st_gold.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_gold.set_material(mat_bronze)
	_add_box(st_gold, Vector3(0, 14.1, 0), Vector3(5.8, 0.35, 5.8), Vector2(2, 1))
	_add_box(st_gold, Vector3(0, 11.8, 2.75), Vector3(2.2, 2.2, 0.25))

	var corners = [Vector3(-9.5, 5.0, -9.5), Vector3(9.5, 5.0, -9.5), Vector3(-9.5, 5.0, 9.5), Vector3(9.5, 5.0, 9.5)]
	for c in corners:
		_add_box(st_gold, c + Vector3(0, 0.5, 0), Vector3(0.9, 1.0, 0.9))
		_add_box(st_gold, c + Vector3(0, 1.1, 0), Vector3(1.3, 0.3, 1.3))

	st_gold.generate_normals()
	st_gold.generate_tangents()
	st_gold.commit(mesh)

	return mesh

func create_city_gate_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_mudbrick)

	_add_box(st, Vector3(-3.8, 3.75, 0), Vector3(3.8, 7.5, 5.0), Vector2(2, 3))
	_add_box(st, Vector3(3.8, 3.75, 0), Vector3(3.8, 7.5, 5.0), Vector2(2, 3))
	_add_box(st, Vector3(0, 6.2, 0), Vector3(4.0, 2.6, 4.5), Vector2(2, 1))

	for mx in [-5.2, -3.8, -2.4, 2.4, 3.8, 5.2]:
		_add_box(st, Vector3(mx, 7.9, 2.2), Vector3(0.6, 0.8, 0.4))
		_add_box(st, Vector3(mx, 7.9, -2.2), Vector3(0.6, 0.8, 0.4))

	_add_box(st, Vector3(-14.8, 2.75, 0), Vector3(18.0, 5.5, 2.8), Vector2(6, 2))
	_add_box(st, Vector3(14.8, 2.75, 0), Vector3(18.0, 5.5, 2.8), Vector2(6, 2))

	for i in range(11):
		_add_box(st, Vector3(-23.0 + i * 1.6, 5.9, 1.2), Vector3(0.8, 0.8, 0.35))
		_add_box(st, Vector3(6.5 + i * 1.6, 5.9, 1.2), Vector3(0.8, 0.8, 0.35))

	st.generate_normals()
	st.generate_tangents()
	st.commit(mesh)

	var st_lapis = SurfaceTool.new()
	st_lapis.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_lapis.set_material(mat_lapis)
	_add_box(st_lapis, Vector3(0, 2.5, 0), Vector3(3.6, 5.0, 0.4), Vector2(1, 2))
	st_lapis.generate_normals()
	st_lapis.generate_tangents()
	st_lapis.commit(mesh)

	return mesh

func create_house_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_mudbrick)
	_add_box(st, Vector3(0, 2.2, 0), Vector3(7.2, 4.4, 5.6), Vector2(3, 2))
	_add_box(st, Vector3(-1.4, 5.2, -0.8), Vector3(3.8, 1.8, 3.2), Vector2(2, 1))
	_add_box(st, Vector3(1.8, 4.7, 1.5), Vector3(3.2, 0.6, 0.3))
	st.generate_normals()
	st.generate_tangents()
	st.commit(mesh)

	var st_w = SurfaceTool.new()
	st_w.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_w.set_material(mat_wood)
	for b in range(5):
		_add_box(st_w, Vector3(0, 4.3, -1.8 + b * 0.9), Vector3(7.6, 0.18, 0.18))
	st_w.generate_normals()
	st_w.generate_tangents()
	st_w.commit(mesh)

	return mesh

func create_granary_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat_mudbrick)
	_add_frustum(st, 0, 0, 2.0, 0, 5.5, 5.5, 5.0, 5.0)
	_add_frustum(st, 0, 2.0, 3.8, 0, 5.0, 5.0, 3.8, 3.8)
	_add_frustum(st, 0, 3.8, 5.0, 0, 3.8, 3.8, 2.2, 2.2)
	_add_frustum(st, 0, 5.0, 5.8, 0, 2.2, 2.2, 0.8, 0.8)
	st.generate_normals()
	st.generate_tangents()
	st.commit(mesh)

	return mesh

func create_palm_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()

	var st_t = SurfaceTool.new()
	st_t.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_t.set_material(mat_wood)
	var pts = [Vector3(0.0, 0.0, 0.0), Vector3(0.25, 2.2, 0.1), Vector3(0.6, 4.5, 0.28), Vector3(1.0, 6.8, 0.45)]
	for i in range(len(pts)-1):
		var p1 = pts[i]; var p2 = pts[i+1]
		var mid = (p1 + p2) * 0.5
		var h = p2.y - p1.y
		_add_box(st_t, mid, Vector3(0.6 - i*0.08, h, 0.6 - i*0.08))
	st_t.generate_normals()
	st_t.generate_tangents()
	st_t.commit(mesh)

	var st_f = SurfaceTool.new()
	st_f.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_f.set_material(mat_frond)
	var apex = pts[-1]
	for idx in range(8):
		var angle = idx * (TAU / 8.0)
		var dir = Vector3(cos(angle), 0, sin(angle))
		var f_mid = apex + dir * 1.8 + Vector3(0, 0.6, 0)
		var f_tip = apex + dir * 3.2 + Vector3(0, -0.6, 0)
		var perp = Vector3(-dir.z, 0, dir.x) * 0.5
		st_f.set_normal(Vector3.UP)
		st_f.set_uv(Vector2(0, 0)); st_f.add_vertex(apex - perp*0.2)
		st_f.set_uv(Vector2(1, 0)); st_f.add_vertex(apex + perp*0.2)
		st_f.set_uv(Vector2(1, 0.5)); st_f.add_vertex(f_mid + perp)
		st_f.set_uv(Vector2(0, 0)); st_f.add_vertex(apex - perp*0.2)
		st_f.set_uv(Vector2(1, 0.5)); st_f.add_vertex(f_mid + perp)
		st_f.set_uv(Vector2(0, 0.5)); st_f.add_vertex(f_mid - perp)
		st_f.set_uv(Vector2(0, 0.5)); st_f.add_vertex(f_mid - perp)
		st_f.set_uv(Vector2(1, 0.5)); st_f.add_vertex(f_mid + perp)
		st_f.set_uv(Vector2(0.5, 1.0)); st_f.add_vertex(f_tip)
	st_f.generate_normals()
	st_f.generate_tangents()
	st_f.commit(mesh)

	return mesh

func create_spearman_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()

	var st_b = SurfaceTool.new()
	st_b.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_b.set_material(mat_bronze)
	_add_box(st_b, Vector3(0, 1.15, 0), Vector3(0.55, 0.7, 0.35))
	_add_box(st_b, Vector3(0, 1.65, 0), Vector3(0.34, 0.34, 0.34))
	_add_frustum(st_b, 0, 1.82, 2.1, 0, 0.34, 0.34, 0.05, 0.05)
	_add_box(st_b, Vector3(0.38, 2.65, 0.2), Vector3(0.12, 0.35, 0.03))
	for sy in [0.7, 1.0, 1.3]:
		_add_box(st_b, Vector3(-0.38, sy, 0.32), Vector3(0.12, 0.12, 0.05))
	st_b.generate_normals()
	st_b.generate_tangents()
	st_b.commit(mesh)

	var st_l = SurfaceTool.new()
	st_l.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_l.set_material(mat_linen)
	_add_box(st_l, Vector3(0, 0.65, 0), Vector3(0.52, 0.35, 0.36))
	_add_box(st_l, Vector3(-0.38, 1.0, 0.25), Vector3(0.55, 1.2, 0.12))
	st_l.generate_normals()
	st_l.generate_tangents()
	st_l.commit(mesh)

	var st_s = SurfaceTool.new()
	st_s.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_s.set_material(mat_skin)
	_add_box(st_s, Vector3(-0.16, 0.25, 0), Vector3(0.18, 0.5, 0.2))
	_add_box(st_s, Vector3(0.16, 0.25, 0), Vector3(0.18, 0.5, 0.2))
	st_s.generate_normals()
	st_s.generate_tangents()
	st_s.commit(mesh)

	var st_w = SurfaceTool.new()
	st_w.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_w.set_material(mat_wood)
	_add_box(st_w, Vector3(0.38, 1.15, 0.2), Vector3(0.06, 2.7, 0.06))
	st_w.generate_normals()
	st_w.generate_tangents()
	st_w.commit(mesh)

	return mesh

func create_slinger_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()

	var st_l = SurfaceTool.new()
	st_l.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_l.set_material(mat_linen)
	_add_box(st_l, Vector3(0, 1.0, 0), Vector3(0.48, 0.8, 0.32))
	_add_box(st_l, Vector3(0, 1.55, 0), Vector3(0.32, 0.32, 0.32))
	st_l.generate_normals()
	st_l.commit(mesh)

	var st_s = SurfaceTool.new()
	st_s.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_s.set_material(mat_skin)
	_add_box(st_s, Vector3(-0.15, 0.25, 0), Vector3(0.16, 0.5, 0.18))
	_add_box(st_s, Vector3(0.15, 0.25, 0), Vector3(0.16, 0.5, 0.18))
	st_s.generate_normals()
	st_s.commit(mesh)

	return mesh

func create_chariot_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()

	var st_w = SurfaceTool.new()
	st_w.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_w.set_material(mat_wood)
	_add_box(st_w, Vector3(0, 0.5, 0), Vector3(1.4, 0.1, 1.6))
	_add_box(st_w, Vector3(0, 0.55, 1.8), Vector3(0.12, 0.12, 2.2))
	_add_box(st_w, Vector3(0, 0.8, 2.8), Vector3(1.8, 0.12, 0.12))
	st_w.generate_normals()
	st_w.commit(mesh)

	var st_b = SurfaceTool.new()
	st_b.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_b.set_material(mat_bronze)
	_add_box(st_b, Vector3(0, 1.0, 0.75), Vector3(1.4, 0.9, 0.12))
	_add_box(st_b, Vector3(-0.68, 0.9, 0.1), Vector3(0.1, 0.7, 1.3))
	_add_box(st_b, Vector3(0.68, 0.9, 0.1), Vector3(0.1, 0.7, 1.3))
	_add_box(st_b, Vector3(-0.85, 0.55, 0), Vector3(0.1, 1.1, 1.1))
	_add_box(st_b, Vector3(0.85, 0.55, 0), Vector3(0.1, 1.1, 1.1))
	_add_box(st_b, Vector3(0.25, 1.65, 0.1), Vector3(0.3, 0.3, 0.3))
	_add_box(st_b, Vector3(-0.25, 1.65, 0.1), Vector3(0.3, 0.3, 0.3))
	st_b.generate_normals()
	st_b.commit(mesh)

	return mesh

func create_farm_mesh() -> ArrayMesh:
	_init_materials()
	var mesh = ArrayMesh.new()

	var st_s = SurfaceTool.new()
	st_s.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_s.set_material(mat_soil)
	_add_box(st_s, Vector3(0, 0.1, 0), Vector3(8.0, 0.2, 8.0), Vector2(4, 4))
	st_s.generate_normals()
	st_s.commit(mesh)

	var st_c = SurfaceTool.new()
	st_c.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_c.set_material(mat_crops)
	for r in [-2.4, -0.8, 0.8, 2.4]:
		for c in range(10):
			var x = -3.0 + c * 0.66
			_add_box(st_c, Vector3(x, 0.55, r), Vector3(0.45, 0.75, 0.45))
	st_c.generate_normals()
	st_c.commit(mesh)

	return mesh
