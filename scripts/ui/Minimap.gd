extends Control

@export var map_world_size: Vector2 = Vector2(120.0, 120.0) # World bounds -60 to +60
var camera_rig: Node3D = null
var parchment_tex: Texture2D = null

func _ready() -> void:
	parchment_tex = _load_tex("res://assets/ui/T_HUD_MinimapParchment_Master.png")
	call_deferred("_find_camera")

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

func _find_camera() -> void:
	camera_rig = get_tree().get_first_node_in_group("CameraRig")
	if not camera_rig:
		camera_rig = get_tree().root.get_node_or_null("Main/CameraRig")

func _process(_delta: float) -> void:
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			var local_pos = event.position
			var norm_x = (local_pos.x / size.x) - 0.5
			var norm_y = (local_pos.y / size.y) - 0.5
			var target_world_x = norm_x * map_world_size.x
			var target_world_z = norm_y * map_world_size.y
			
			if camera_rig and is_instance_valid(camera_rig):
				camera_rig.global_position.x = target_world_x
				camera_rig.global_position.z = target_world_z

func _draw() -> void:
	# 1. Parchment Map Base Texture
	if parchment_tex:
		draw_texture_rect(parchment_tex, Rect2(Vector2.ZERO, size), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.14, 0.11, 0.08, 0.98), true)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.70, 0.55, 0.28, 0.9), false, 2.0)

	# 2. Euphrates River Highlight
	var river_pts = [
		_world_to_map(Vector3(-55.0, 0.0, -40.0)),
		_world_to_map(Vector3(-20.0, 0.0, -10.0)),
		_world_to_map(Vector3(15.0, 0.0, 20.0)),
		_world_to_map(Vector3(55.0, 0.0, 50.0))
	]
	for i in range(river_pts.size() - 1):
		draw_line(river_pts[i], river_pts[i+1], Color(0.25, 0.55, 0.75, 0.7), 3.5)

	# 3. Ziggurat Capital blip (Gold Diamond)
	var zig_pos = _world_to_map(Vector3(0.0, 0.0, 0.0))
	var diamond = [
		zig_pos + Vector2(0, -6),
		zig_pos + Vector2(6, 0),
		zig_pos + Vector2(0, 6),
		zig_pos + Vector2(-6, 0)
	]
	draw_colored_polygon(PackedVector2Array(diamond), Color(1.0, 0.88, 0.25, 1.0))
	draw_polyline(PackedVector2Array(diamond + [diamond[0]]), Color(0.2, 0.15, 0.05), 1.5)

	# 4. Enemy Citadel blip (Crimson Fortress)
	var enemy_citadels = get_tree().get_nodes_in_group("EnemyCitadel")
	for ec in enemy_citadels:
		if is_instance_valid(ec):
			var ec_pos = _world_to_map(ec.global_position)
			draw_rect(Rect2(ec_pos - Vector2(5, 5), Vector2(10, 10)), Color(0.95, 0.25, 0.25), true)
			draw_rect(Rect2(ec_pos - Vector2(6, 6), Vector2(12, 12)), Color(0.2, 0.05, 0.05), false, 1.5)
	
	# 5. Units blips
	var units = get_tree().get_nodes_in_group("Units")
	for u in units:
		if is_instance_valid(u):
			var upos = _world_to_map(u.global_position)
			var team = u.get("team_id") if "team_id" in u else 0
			var ucol = Color(0.35, 0.82, 1.0) if team == 0 else Color(1.0, 0.3, 0.3)
			var is_sel = u.get("is_selected") if "is_selected" in u else false
			if is_sel:
				draw_circle(upos, 5.0, Color(1.0, 0.92, 0.3))
				draw_circle(upos, 3.5, ucol)
			else:
				draw_circle(upos, 3.0, ucol)

	# 6. Camera Viewport Frustum Box
	if camera_rig and is_instance_valid(camera_rig):
		var cam_pos = _world_to_map(camera_rig.global_position)
		var view_box = Rect2(cam_pos - Vector2(18, 14), Vector2(36, 28))
		draw_rect(view_box, Color(1.0, 0.95, 0.6, 0.7), false, 1.5)

func _world_to_map(world_pos: Vector3) -> Vector2:
	var nx = (world_pos.x / map_world_size.x) + 0.5
	var ny = (world_pos.z / map_world_size.y) + 0.5
	return Vector2(clamp(nx, 0.0, 1.0) * size.x, clamp(ny, 0.0, 1.0) * size.y)
