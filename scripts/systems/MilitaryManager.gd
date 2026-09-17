extends Node

var selected_units: Array[Node] = []
var all_units: Array[Node] = []

func register_unit(unit: Node) -> void:
	if not all_units.has(unit):
		all_units.append(unit)
		EventBus.unit_spawned.emit(unit)

func unregister_unit(unit: Node) -> void:
	all_units.erase(unit)
	selected_units.erase(unit)
	EventBus.unit_killed.emit(unit)
	EventBus.units_selected.emit(selected_units)

func select_unit(unit: Node, additive: bool = false) -> void:
	if not additive:
		clear_selection()
	if is_instance_valid(unit) and not selected_units.has(unit):
		selected_units.append(unit)
		if unit.has_method("set_selected"):
			unit.set_selected(true)
	EventBus.units_selected.emit(selected_units)

func clear_selection() -> void:
	for u in selected_units:
		if is_instance_valid(u) and u.has_method("set_selected"):
			u.set_selected(false)
	selected_units.clear()
	EventBus.units_selected.emit(selected_units)

func select_in_box(box_rect: Rect2, camera: Camera3D) -> void:
	clear_selection()
	for u in all_units:
		if is_instance_valid(u) and u.team_id == 0:
			var screen_pos = camera.unproject_position(u.global_position)
			if box_rect.has_point(screen_pos):
				selected_units.append(u)
				if u.has_method("set_selected"):
					u.set_selected(true)
	EventBus.units_selected.emit(selected_units)

func issue_move_order(target_pos: Vector3) -> void:
	if selected_units.is_empty():
		return
	
	var count = selected_units.size()
	var avg_pos = Vector3.ZERO
	for u in selected_units:
		if is_instance_valid(u):
			avg_pos += u.global_position
	avg_pos /= max(1, count)
	
	var facing = (target_pos - avg_pos).normalized()
	var slots = FormationManager.get_formation_slots(FormationManager.FormationType.PHALANX, count, target_pos, facing)
	
	for i in range(count):
		var u = selected_units[i]
		if is_instance_valid(u) and u.has_method("move_to_position"):
			u.move_to_position(slots[i])

func issue_attack_order(target_enemy: Node) -> void:
	for u in selected_units:
		if is_instance_valid(u) and u.has_method("attack_target"):
			u.attack_target(target_enemy)

func spawn_raider_wave(count: int, spawn_pos: Vector3, world_node: Node) -> void:
	var unit_scene = load("res://scenes/units/Unit.tscn")
	var raider_data = load("res://data/units/Raider.tres")
	
	for i in range(count):
		var raider = unit_scene.instantiate()
		raider.unit_data = raider_data
		raider.team_id = 1
		var offset = Vector3(randf_range(-5.0, 5.0), 0.0, randf_range(-5.0, 5.0))
		var units_node = world_node.get_node_or_null("Units")
		if not units_node:
			units_node = world_node
		units_node.add_child(raider)
		raider.global_position = spawn_pos + offset
		raider.move_to_position(Vector3(0.0, 0.0, 0.0))
	
	EventBus.notification_posted.emit("INVASION ALERT", "Nomadic Gutian raiders advancing from the North Gate!", Color(0.95, 0.2, 0.2))
