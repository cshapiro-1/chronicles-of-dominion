extends Control

@export var map_world_size: Vector2 = Vector2(120.0, 120.0) # World bounds -60 to +60
var camera_rig: Node3D = null

func _ready() -> void:
	call_deferred("_find_camera")

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
	# Outer parchment map background
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.12, 0.10, 0.08, 0.95), true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.6, 0.48, 0.24, 0.9), false, 2.0)
	
	# Grid lines
	var center = size * 0.5
	draw_line(Vector2(0, center.y), Vector2(size.x, center.y), Color(0.25, 0.22, 0.18, 0.4), 1.0)
	draw_line(Vector2(center.x, 0), Vector2(center.x, size.y), Color(0.25, 0.22, 0.18, 0.4), 1.0)
	
	# River curve
	var river_pts = [
		_world_to_map(Vector3(-55.0, 0.0, -40.0)),
		_world_to_map(Vector3(-20.0, 0.0, -10.0)),
		_world_to_map(Vector3(15.0, 0.0, 20.0)),
		_world_to_map(Vector3(55.0, 0.0, 50.0))
	]
	for i in range(river_pts.size() - 1):
		draw_line(river_pts[i], river_pts[i+1], Color(0.2, 0.45, 0.65, 0.8), 4.0)

	# Ziggurat Capital blip
	var zig_pos = _world_to_map(Vector3(0.0, 0.0, 0.0))
	draw_rect(Rect2(zig_pos - Vector2(5, 5), Vector2(10, 10)), Color(1.0, 0.84, 0.2), true)
	draw_rect(Rect2(zig_pos - Vector2(6, 6), Vector2(12, 12)), Color(0.2, 0.15, 0.05), false, 1.0)
	
	# Units blips
	var units = get_tree().get_nodes_in_group("Units")
	for u in units:
		if is_instance_valid(u):
			var upos = _world_to_map(u.global_position)
			var team = u.get("team_id") if "team_id" in u else 0
			var ucol = Color(0.3, 0.75, 1.0) if team == 0 else Color(0.95, 0.2, 0.2)
			if u.is_selected:
				draw_circle(upos, 5.0, Color(1.0, 0.9, 0.2))
				draw_circle(upos, 3.5, ucol)
			else:
				draw_circle(upos, 3.0, ucol)

	# Camera frustum / view rect
	if camera_rig and is_instance_valid(camera_rig):
		var cam_pos = _world_to_map(camera_rig.global_position)
		var view_box = Rect2(cam_pos - Vector2(16, 12), Vector2(32, 24))
		draw_rect(view_box, Color(1.0, 1.0, 1.0, 0.5), false, 1.5)

func _world_to_map(world_pos: Vector3) -> Vector2:
	var nx = (world_pos.x / map_world_size.x) + 0.5
	var ny = (world_pos.z / map_world_size.y) + 0.5
	return Vector2(clamp(nx, 0.0, 1.0) * size.x, clamp(ny, 0.0, 1.0) * size.y)
