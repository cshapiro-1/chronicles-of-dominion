class_name ArealUnitSelectionHandler
extends Control

var is_dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var drag_end: Vector2 = Vector2.ZERO
var camera: Camera3D = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func start_drag(pos: Vector2) -> void:
	is_dragging = true
	drag_start = pos
	drag_end = pos
	queue_redraw()

func update_drag(pos: Vector2) -> void:
	if is_dragging:
		drag_end = pos
		queue_redraw()

func end_drag() -> Array:
	if not is_dragging:
		return []
	is_dragging = false
	queue_redraw()
	
	var rect = Rect2(drag_start, drag_end - drag_start).abs()
	if rect.size.x < 5.0 and rect.size.y < 5.0:
		return [] # Single click, not drag box
		
	camera = get_viewport().get_camera_3d()
	if not camera:
		return []
		
	var selected = []
	var units = get_tree().get_nodes_in_group("Units")
	
	for u in units:
		if not is_instance_valid(u) or not (u is Node3D):
			continue
		if u.get("team_id") != 0:
			continue
			
		var pos = u.global_position
		if camera.is_position_behind(pos):
			continue
			
		# 1. Direct center test
		var screen_center = camera.unproject_position(pos)
		if rect.has_point(screen_center):
			selected.append(u)
			continue
			
		# 2. Comprehensive 3D bounding extents test
		var points_to_check = [
			pos + Vector3(0, 2.8, 0),
			pos + Vector3(-2.2, 0, -2.2),
			pos + Vector3(2.2, 0, -2.2),
			pos + Vector3(-2.2, 0, 2.2),
			pos + Vector3(2.2, 0, 2.2)
		]
		
		# Include all soldier nodes within squad
		var squad = u.get_node_or_null("SquadRoot")
		if squad:
			for soldier in squad.get_children():
				if soldier is Node3D:
					points_to_check.append(soldier.global_position)
					
		var touches_box = false
		var min_x = screen_center.x
		var max_x = screen_center.x
		var min_y = screen_center.y
		var max_y = screen_center.y
		
		for pt in points_to_check:
			if not camera.is_position_behind(pt):
				var sp = camera.unproject_position(pt)
				if rect.has_point(sp):
					touches_box = true
					break
				min_x = min(min_x, sp.x)
				max_x = max(max_x, sp.x)
				min_y = min(min_y, sp.y)
				max_y = max(max_y, sp.y)
				
		if touches_box:
			selected.append(u)
		else:
			# Check if unit 2D screen bounding box intersects selection rectangle
			var unit_rect = Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
			if rect.intersects(unit_rect):
				selected.append(u)
				
	return selected

func _draw() -> void:
	if is_dragging:
		var rect = Rect2(drag_start, drag_end - drag_start).abs()
		if rect.size.x > 3.0 or rect.size.y > 3.0:
			draw_rect(rect, Color(0.35, 0.85, 0.45, 0.18), true)
			draw_rect(rect, Color(0.45, 0.95, 0.55, 0.9), false, 1.8)
