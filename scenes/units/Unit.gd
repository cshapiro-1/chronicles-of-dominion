extends CharacterBody3D

@export var unit_data: Resource = null
@export var unit_type: String = "spearman"
@export var team_id: int = 0 # 0 = Player, 1 = Hostile Raider
@export var max_hp: float = 120.0
@export var move_speed: float = 5.5
@export var attack_range: float = 3.2
@export var attack_damage: float = 24.0
@export var attack_interval: float = 1.2
@export var aggro_radius: float = 14.0
@export var is_ranged: bool = false
@export var active_formation: String = "Phalanx"

@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var hp_bar: Label3D = $HPBar
@onready var squad_root: Node3D = $SquadRoot
@onready var nav_agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D")

var is_selected: bool = false
var target_destination: Vector3
var has_target: bool = false
var target_facing_yaw: float = 0.0
var has_target_facing: bool = false
var current_hp: float = 120.0
var is_moving: bool = false
var march_time: float = 0.0
var soldier_nodes: Array[Node3D] = []

var target_enemy: Node3D = null
var attack_timer: float = 0.0

# Preload Unit Model & Projectile Scenes
const SCENE_SPEARMAN = preload("res://assets/models/unit_akkadian_spearman.tscn")
const SCENE_SLINGER = preload("res://assets/models/unit_mesopotamian_slinger.tscn")
const SCENE_CHARIOT = preload("res://assets/models/unit_sumerian_war_chariot.tscn")
const SCENE_BAGGAGE = preload("res://assets/models/unit_ox_baggage_train.tscn")
const SCENE_RAIDER = preload("res://assets/models/unit_nomad_desert_raider.tscn")
const SCENE_PROJECTILE = preload("res://scenes/combat/Projectile.tscn")

func _ready() -> void:
	add_to_group("Units")
	if MilitaryManager:
		MilitaryManager.register_unit(self)
	_apply_unit_stats()
	current_hp = max_hp
	target_destination = global_position
	
	if nav_agent:
		nav_agent.path_desired_distance = 0.8
		nav_agent.target_desired_distance = 1.2
		nav_agent.path_max_distance = 3.0
	
	if selection_ring:
		selection_ring.visible = false
		selection_ring.position.y = 0.08
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(0.2, 1.0, 0.45) if team_id == 0 else Color(1.0, 0.25, 0.25)
		selection_ring.material_override = mat
		var t_lower = unit_type.to_lower()
		if "chariot" in t_lower:
			selection_ring.scale = Vector3(1.6, 1.0, 1.6)
		else:
			selection_ring.scale = Vector3(1.15, 1.0, 1.15)

	update_hp_display()
	_build_squad()

func _exit_tree() -> void:
	if MilitaryManager:
		MilitaryManager.unregister_unit(self)

func _apply_unit_stats() -> void:
	if unit_data:
		if "unit_name" in unit_data:
			unit_type = unit_data.unit_name.to_lower()
		if "max_health" in unit_data:
			max_hp = unit_data.max_health
		if "move_speed" in unit_data:
			move_speed = unit_data.move_speed
		if "damage" in unit_data:
			attack_damage = unit_data.damage
		if "attack_range" in unit_data:
			attack_range = unit_data.attack_range
		if "attack_speed" in unit_data and unit_data.attack_speed > 0:
			attack_interval = 1.0 / unit_data.attack_speed
		if "is_ranged" in unit_data:
			is_ranged = unit_data.is_ranged
		return
	var t = unit_type.to_lower()
	if "slinger" in t or "archer" in t:
		max_hp = 80.0
		move_speed = 5.8
		attack_range = 18.0
		attack_damage = 18.0
		attack_interval = 1.5
		is_ranged = true
	elif "chariot" in t:
		max_hp = 260.0
		move_speed = 8.2
		attack_range = 4.0
		attack_damage = 50.0
		attack_interval = 1.6
		is_ranged = false
	elif "raider" in t or "nomad" in t:
		max_hp = 95.0
		move_speed = 6.2
		attack_range = 3.0
		attack_damage = 18.0
		attack_interval = 1.1
		team_id = 1
		is_ranged = false
	else:
		# Spearman
		max_hp = 140.0
		move_speed = 5.2
		attack_range = 3.2
		attack_damage = 22.0
		attack_interval = 1.1
		is_ranged = false

func _build_squad() -> void:
	for child in squad_root.get_children():
		child.queue_free()
	soldier_nodes.clear()
	
	var type_lower = unit_type.to_lower()
	if "chariot" in type_lower:
		var chariot_inst = SCENE_CHARIOT.instantiate()
		squad_root.add_child(chariot_inst)
		soldier_nodes.append(chariot_inst)
		MeshFactory.apply_pbr_to_tree(chariot_inst)
	elif "baggage" in type_lower or "ox" in type_lower:
		var baggage_inst = SCENE_BAGGAGE.instantiate()
		squad_root.add_child(baggage_inst)
		soldier_nodes.append(baggage_inst)
		MeshFactory.apply_pbr_to_tree(baggage_inst)
	elif "raider" in type_lower or "nomad" in type_lower:
		var raider_offsets = [
			Vector3(-1.0, 0, -0.6), Vector3(0.0, 0, -0.8), Vector3(1.0, 0, -0.6),
			Vector3(-0.7, 0, 0.7), Vector3(0.7, 0, 0.7)
		]
		for offset in raider_offsets:
			var r_inst = SCENE_RAIDER.instantiate()
			r_inst.position = offset
			squad_root.add_child(r_inst)
			soldier_nodes.append(r_inst)
			MeshFactory.apply_pbr_to_tree(r_inst)
	elif "slinger" in type_lower or "archer" in type_lower:
		var slinger_offsets = [
			Vector3(-1.4, 0, -0.6), Vector3(0.0, 0, -0.8), Vector3(1.4, 0, -0.6),
			Vector3(-1.0, 0, 0.8), Vector3(1.0, 0, 0.8), Vector3(0.0, 0, 1.4)
		]
		for offset in slinger_offsets:
			var s_inst = SCENE_SLINGER.instantiate()
			s_inst.position = offset
			squad_root.add_child(s_inst)
			soldier_nodes.append(s_inst)
			MeshFactory.apply_pbr_to_tree(s_inst)
	else:
		# 3x3 Phalanx of Akkadian Spearmen
		for r in range(3):
			for c in range(3):
				var s_inst = SCENE_SPEARMAN.instantiate()
				s_inst.position = Vector3((c - 1) * 1.0, 0, (r - 1) * 1.0)
				squad_root.add_child(s_inst)
				soldier_nodes.append(s_inst)
				MeshFactory.apply_pbr_to_tree(s_inst)

var nav_path: PackedVector3Array = PackedVector3Array()
var nav_path_idx: int = 0
var stuck_timer: float = 0.0
var last_progress_pos: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	attack_timer = max(0.0, attack_timer - delta)
	
	# 1. Combat & Target Tracking
	if is_instance_valid(target_enemy):
		var dist_to_enemy = global_position.distance_to(target_enemy.global_position)
		if dist_to_enemy <= attack_range:
			# In range -> Stop and Attack
			velocity = Vector3.ZERO
			is_moving = false
			march_time = 0.0
			_reset_stance(true)
			_face_target(target_enemy.global_position, delta)
			if attack_timer <= 0.0:
				_perform_attack(target_enemy)
		else:
			# Out of range -> Chase enemy using NavigationServer path
			if nav_path_idx >= nav_path.size() or nav_path.is_empty():
				_calculate_combat_chase_path(target_enemy.global_position)
			
			if nav_path_idx < nav_path.size():
				var curr_wp = nav_path[nav_path_idx]
				curr_wp.y = global_position.y
				if global_position.distance_to(curr_wp) <= 2.0:
					nav_path_idx += 1
				if nav_path_idx < nav_path.size():
					_move_towards(nav_path[nav_path_idx], delta)
				else:
					_move_towards(target_enemy.global_position, delta)
			else:
				_move_towards(target_enemy.global_position, delta)
	elif has_target:
		# 2. Moving to Waypoint via NavPath
		if nav_path_idx >= nav_path.size() or nav_path.is_empty():
			# Reached final waypoint
			is_moving = false
			velocity = Vector3.ZERO
			has_target = false
			march_time = 0.0
			stuck_timer = 0.0
			_reset_stance(true)
			if has_target_facing:
				squad_root.rotation.y = target_facing_yaw
		else:
			var curr_target = nav_path[nav_path_idx]
			curr_target.y = global_position.y
			var dist = global_position.distance_to(curr_target)
			
			# If reached current waypoint, advance to next
			if dist <= 2.2:
				nav_path_idx += 1
				if nav_path_idx >= nav_path.size():
					# Final waypoint reached
					is_moving = false
					velocity = Vector3.ZERO
					has_target = false
					march_time = 0.0
					stuck_timer = 0.0
					_reset_stance(true)
					if has_target_facing:
						squad_root.rotation.y = target_facing_yaw
					return
				curr_target = nav_path[nav_path_idx]
				curr_target.y = global_position.y
				
			# Stuck detection and recovery: if trapped on static corner, recalculate path
			if global_position.distance_to(last_progress_pos) < 0.12 * move_speed * delta:
				stuck_timer += delta
				if stuck_timer > 0.45:
					_calculate_navigation_path()
					stuck_timer = 0.0
			else:
				stuck_timer = max(0.0, stuck_timer - delta * 2.0)
			last_progress_pos = global_position
			
			_move_towards(curr_target, delta)
	else:
		# 3. Idle -> Face target orientation if set, and scan for enemies
		velocity = Vector3.ZERO
		is_moving = false
		march_time = 0.0
		stuck_timer = 0.0
		_reset_stance(true)
		if has_target_facing:
			squad_root.rotation.y = lerp_angle(squad_root.rotation.y, target_facing_yaw, 10.0 * delta)
		_scan_for_enemies()

func _calculate_navigation_path() -> void:
	var world3d = get_world_3d()
	if world3d and world3d.navigation_map.is_valid():
		var map = world3d.navigation_map
		var clean_start = NavigationServer3D.map_get_closest_point(map, global_position)
		var clean_dest = NavigationServer3D.map_get_closest_point(map, target_destination)
		if clean_dest == Vector3.ZERO:
			clean_dest = target_destination
		var path = NavigationServer3D.map_get_path(map, clean_start, clean_dest, true)
		if path.size() > 1:
			nav_path = path
			nav_path_idx = 1
			return
	nav_path = PackedVector3Array([global_position, target_destination])
	nav_path_idx = 1

func _calculate_combat_chase_path(enemy_pos: Vector3) -> void:
	var world3d = get_world_3d()
	if world3d and world3d.navigation_map.is_valid():
		var map = world3d.navigation_map
		var clean_start = NavigationServer3D.map_get_closest_point(map, global_position)
		var clean_dest = NavigationServer3D.map_get_closest_point(map, enemy_pos)
		if clean_dest == Vector3.ZERO:
			clean_dest = enemy_pos
		var path = NavigationServer3D.map_get_path(map, clean_start, clean_dest, true)
		if path.size() > 1:
			nav_path = path
			nav_path_idx = 1
			return
	nav_path = PackedVector3Array([global_position, enemy_pos])
	nav_path_idx = 1


func _compute_crowd_separation() -> Vector3:
	var sep = Vector3.ZERO
	var units = get_tree().get_nodes_in_group("Units")
	for u in units:
		if u != self and is_instance_valid(u) and u.get("team_id") == team_id:
			var diff = global_position - u.global_position
			diff.y = 0.0
			var d2 = diff.length_squared()
			if d2 > 0.01 and d2 < 6.25: # within ~2.5m
				var d = sqrt(d2)
				sep += diff.normalized() * (1.0 - d / 2.5) * 1.0
	return sep

func _move_towards(dest: Vector3, delta: float) -> void:
	var dir = (dest - global_position)
	dir.y = 0.0
	var dist = dir.length()
	
	if dist > 0.15:
		is_moving = true
		var move_dir = dir.normalized()
		var sep = _compute_crowd_separation()
		
		# Cap separation force to at most 20% of move speed
		sep = sep.limit_length(move_speed * 0.20)
		
		# Prevent separation from pushing backwards against travel direction
		var dot = sep.dot(move_dir)
		if dot < 0.0:
			sep -= move_dir * dot
			
		velocity = move_dir * move_speed + sep
		
		var target_rot_y = atan2(move_dir.x, move_dir.z)
		squad_root.rotation.y = lerp_angle(squad_root.rotation.y, target_rot_y, 12.0 * delta)
		
		march_time += delta * move_speed * 2.8
		_animate_marching()
		
		move_and_slide()
	else:
		velocity = Vector3.ZERO




func _face_target(target_pos: Vector3, delta: float) -> void:
	var dir = (target_pos - global_position)
	dir.y = 0.0
	if dir.length() > 0.1:
		var target_rot_y = atan2(dir.x, dir.z)
		squad_root.rotation.y = lerp_angle(squad_root.rotation.y, target_rot_y, 14.0 * delta)

func _perform_attack(enemy: Node3D) -> void:
	attack_timer = attack_interval
	
	if is_ranged:
		# Ranged Ballistic Volley
		_launch_ranged_projectile(enemy)
	else:
		# Melee Strike
		_animate_attack_lunge()
		if enemy.has_method("take_damage"):
			enemy.take_damage(attack_damage, global_position, false)
			
	# Show combat text notification on first hit
	if team_id == 0 and randf() < 0.25:
		EventBus.post_notification("IN COMBAT", "%s cohort engaging hostile forces!" % unit_type.capitalize(), Color(1.0, 0.85, 0.3))

func _launch_ranged_projectile(enemy: Node3D) -> void:
	# Quick soldier recoil animation
	for s in soldier_nodes:
		var tween = create_tween()
		var orig_y = s.position.y
		tween.tween_property(s, "position:y", orig_y + 0.12, 0.08)
		tween.tween_property(s, "position:y", orig_y, 0.14)
		
	var proj_inst = SCENE_PROJECTILE.instantiate()
	var spawn_pos = global_position + Vector3(0, 1.6, 0)
	var p_type = "arrow" if "archer" in unit_type.to_lower() else "stone"
	get_tree().root.get_node_or_null("Main/World").add_child(proj_inst)
	proj_inst.launch(spawn_pos, enemy, attack_damage, p_type)

func _animate_attack_lunge() -> void:
	for s in soldier_nodes:
		var tween = create_tween()
		var orig_z = s.position.z
		tween.tween_property(s, "position:z", orig_z + 0.35, 0.1).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(s, "position:z", orig_z, 0.18).set_trans(Tween.TRANS_SINE)

func _scan_for_enemies() -> void:
	var units = get_tree().get_nodes_in_group("Units")
	var closest_enemy: Node3D = null
	var closest_dist: float = aggro_radius
	
	for u in units:
		if is_instance_valid(u) and u != self and u.get("team_id") != team_id:
			var d = global_position.distance_to(u.global_position)
			if d < closest_dist:
				closest_dist = d
				closest_enemy = u
				
	if closest_enemy:
		target_enemy = closest_enemy

func _animate_marching() -> void:
	for i in range(soldier_nodes.size()):
		var s = soldier_nodes[i]
		if is_instance_valid(s):
			var phase = march_time + i * 0.45
			s.position.y = abs(sin(phase)) * 0.08
			s.rotation.x = sin(phase) * 0.08
			s.rotation.z = cos(phase) * 0.04

func _reset_stance(immediate: bool = false) -> void:
	for s in soldier_nodes:
		if is_instance_valid(s):
			if immediate:
				s.position.y = 0.0
				s.rotation.x = 0.0
				s.rotation.z = 0.0
			else:
				s.position.y = move_toward(s.position.y, 0.0, 0.015)
				s.rotation.x = move_toward(s.rotation.x, 0.0, 0.015)
				s.rotation.z = move_toward(s.rotation.z, 0.0, 0.015)

func set_target_destination(dest: Vector3, facing_yaw: float = 0.0, apply_facing: bool = false) -> void:
	target_enemy = null # Manual move cancels current attack target
	var clean_dest = Vector3(dest.x, global_position.y, dest.z)
	var world3d = get_world_3d()
	if world3d and world3d.navigation_map.is_valid():
		var closest = NavigationServer3D.map_get_closest_point(world3d.navigation_map, clean_dest)
		if closest != Vector3.ZERO:
			clean_dest = Vector3(closest.x, global_position.y, closest.z)
	target_destination = clean_dest
	has_target = true
	has_target_facing = apply_facing
	target_facing_yaw = facing_yaw
	stuck_timer = 0.0
	last_progress_pos = global_position
	_calculate_navigation_path()

func move_to_position(dest: Vector3) -> void:
	set_target_destination(dest)

func attack_target(enemy: Node3D) -> void:
	target_enemy = enemy
	has_target = false
	if is_instance_valid(enemy):
		_calculate_combat_chase_path(enemy.global_position)



func set_selected(val: bool) -> void:
	if val:
		select()
	else:
		deselect()

func select() -> void:
	is_selected = true
	if selection_ring:
		selection_ring.visible = true

func deselect() -> void:
	is_selected = false
	if selection_ring:
		selection_ring.visible = false

func take_damage(amount: float, attack_origin: Vector3 = Vector3.ZERO, is_projectile: bool = false) -> void:
	var final_damage = amount
	
	if attack_origin != Vector3.ZERO:
		var forward_dir = -squad_root.global_transform.basis.z
		forward_dir.y = 0.0
		forward_dir = forward_dir.normalized()
		
		var attack_dir = (attack_origin - global_position)
		attack_dir.y = 0.0
		attack_dir = attack_dir.normalized()
		
		var dot = forward_dir.dot(attack_dir) # 1.0 = attacker in front, -1.0 = attacker behind
		
		# 1. Rear Flank Strike Vulnerability (+50% dmg)
		if dot < -0.3:
			final_damage *= 1.5
			if team_id == 0 and randf() < 0.3:
				EventBus.post_notification("FLANKED!", "%s cohort struck from the rear!" % unit_type.capitalize(), Color(1.0, 0.45, 0.2))
		
		# 2. Phalanx Frontal Shield Wall (-40% melee dmg)
		elif dot > 0.4 and active_formation == "Phalanx" and not is_projectile:
			final_damage *= 0.6
			
		# 3. Skirmish Dispersion vs Projectiles (-35% missile dmg)
		if is_projectile and active_formation == "Skirmish":
			final_damage *= 0.65
			
		# 4. Elevation Advantage (+25% dmg from high ground)
		if attack_origin.y > global_position.y + 0.5:
			final_damage *= 1.25
			
	current_hp = max(0.0, current_hp - final_damage)
	update_hp_display()
	
	# Hit flash on soldiers
	for s in soldier_nodes:
		var tw = create_tween()
		tw.tween_property(s, "scale", Vector3(1.1, 0.9, 1.1), 0.05)
		tw.tween_property(s, "scale", Vector3(1.0, 1.0, 1.0), 0.08)
		
	if current_hp <= 0:
		_die()

func _die() -> void:
	if team_id == 1:
		EventBus.post_notification("ENEMY DEFEATED", "Hostile %s regiment eliminated." % unit_type.capitalize(), Color(0.4, 1.0, 0.4))
		EconomyManager.resources["Gold"] = EconomyManager.resources.get("Gold", 0) + 50
	else:
		EventBus.post_notification("CASUALTIES", "Allied %s regiment destroyed." % unit_type.capitalize(), Color(1.0, 0.3, 0.3))
		
	queue_free()

func update_hp_display() -> void:
	if not hp_bar:
		return
	hp_bar.text = "%d / %d" % [int(current_hp), int(max_hp)]
	var ratio = current_hp / max_hp
	if ratio > 0.6:
		hp_bar.modulate = Color(0.4, 0.95, 0.4)
	elif ratio > 0.3:
		hp_bar.modulate = Color(1.0, 0.85, 0.3)
	else:
		hp_bar.modulate = Color(1.0, 0.25, 0.25)

