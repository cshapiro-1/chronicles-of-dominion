extends Control

var is_dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var drag_end: Vector2 = Vector2.ZERO

@export var camera: Camera3D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start = event.position
				drag_end = drag_start
				queue_redraw()
			else:
				if is_dragging:
					is_dragging = false
					_perform_selection()
					queue_redraw()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_issue_command_at_mouse(event.position)
	
	elif event is InputEventMouseMotion and is_dragging:
		drag_end = event.position
		queue_redraw()

func _draw() -> void:
	if is_dragging and drag_start.distance_to(drag_end) > 4.0:
		var rect = Rect2(drag_start, drag_end - drag_start).abs()
		draw_rect(rect, Color(0.9, 0.75, 0.3, 0.15), true)
		draw_rect(rect, Color(0.95, 0.82, 0.35, 0.9), false, 1.8)

func _perform_selection() -> void:
	var rect = Rect2(drag_start, drag_end - drag_start).abs()
	if rect.size.length() < 8.0:
		_single_click_select(drag_start)
	else:
		if camera:
			MilitaryManager.select_in_box(rect, camera)

func _single_click_select(screen_pos: Vector2) -> void:
	if not camera: return
	var from = camera.project_ray_origin(screen_pos)
	var dir = camera.project_ray_normal(screen_pos)
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, from + dir * 500.0)
	query.collision_mask = 1 | 2
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		if collider and collider.is_in_group("Units"):
			MilitaryManager.select_unit(collider, Input.is_key_pressed(KEY_SHIFT))
		else:
			MilitaryManager.clear_selection()
	else:
		MilitaryManager.clear_selection()

func _issue_command_at_mouse(screen_pos: Vector2) -> void:
	if not camera: return
	var from = camera.project_ray_origin(screen_pos)
	var dir = camera.project_ray_normal(screen_pos)
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, from + dir * 500.0)
	var result = space_state.intersect_ray(query)
	
	if result:
		var target_pos = result.position
		var collider = result.collider
		if collider and collider.is_in_group("Units") and collider.team_id != 0:
			MilitaryManager.issue_attack_order(collider)
		else:
			MilitaryManager.issue_move_order(target_pos)
