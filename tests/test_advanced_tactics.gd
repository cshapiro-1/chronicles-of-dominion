extends SceneTree

func _init() -> void:
	print("==================================================")
	print("--- ADVANCED TACTICAL RTS MECHANICS TEST ---")
	print("==================================================")
	call_deferred("_run_test")

func _run_test() -> void:
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main_scene)
	
	await create_timer(0.3).timeout
	
	var hud = root.get_node_or_null("Main/UI/HUD")
	assert(hud != null, "HUD must exist")
	
	# 1. Test Flat Ground
	var ground = root.get_node_or_null("Main/World/Ground/MeshInstance3D")
	assert(ground != null and ground.visible == true, "Flat ground plane must be active and visible")
	print("[1/4] Flat Ground Battlefield Verified.")
	
	# 2. Test Ranged Ballistic Projectile
	hud._spawn_unit("archer")
	hud._spawn_hostile_raider()
	await create_timer(0.2).timeout
	
	var archer = null
	var raider = null
	for u in root.get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u):
			if u.get("is_ranged") == true and u.get("team_id") == 0:
				archer = u
			elif u.get("team_id") == 1:
				raider = u
				
	assert(archer != null, "Ranged archer must be spawned")
	assert(raider != null, "Enemy raider must be spawned")
	
	var raider_hp_start = raider.current_hp
	archer._perform_attack(raider)
	print("[2/4] Ranged Volley Fired: Projectile launched towards raider.")
	
	# Wait for projectile flight and impact
	await create_timer(0.6).timeout
	assert(raider.current_hp < raider_hp_start, "Ranged projectile must strike target and deal damage")
	print("      Projectile Impact Confirmed: Raider HP dropped from %d to %d" % [int(raider_hp_start), int(raider.current_hp)])
	
	# 3. Test Drag-to-Orient Formation Facing
	hud._select_units([archer])
	hud._issue_facing_move_order(Vector2(500, 400), Vector2(500, 200)) # Drag pointing north
	await create_timer(0.1).timeout
	assert(archer.has_target_facing == true, "Unit must receive directional facing command")
	print("[3/4] Drag-to-Orient Facing Command Verified.")
	
	# 4. Test Tactical Flanking Bonus vs Phalanx Frontal Shield Wall
	var test_unit = archer
	test_unit.max_hp = 200.0
	test_unit.current_hp = 200.0
	test_unit.active_formation = "Phalanx"
	test_unit.squad_root.rotation.y = 0.0 # Facing -Z (North)
	
	# Frontal attack (attacker is north at 0, 0, -10)
	var hp_before_front = test_unit.current_hp
	test_unit.take_damage(50.0, test_unit.global_position + Vector3(0, 0, -10), false)
	var front_damage_taken = hp_before_front - test_unit.current_hp
	print("      Phalanx Frontal Shield Wall: 50 base damage reduced to %.1f damage" % front_damage_taken)
	assert(front_damage_taken < 50.0, "Phalanx front shield wall must absorb damage")
	
	# Rear Flanking attack (attacker is south at 0, 0, +10)
	var hp_before_rear = test_unit.current_hp
	test_unit.take_damage(50.0, test_unit.global_position + Vector3(0, 0, 10), false)
	var rear_damage_taken = hp_before_rear - test_unit.current_hp
	print("      Rear Flanking Attack: 50 base damage amplified to %.1f damage (+50%% bonus)" % rear_damage_taken)
	assert(rear_damage_taken > 50.0, "Flanking from behind must deal amplified damage")
	print("[4/4] Flanking Multipliers and Formation Defenses Verified.")
	
	print("==================================================")
	print(">>> ALL ADVANCED TACTICAL MECHANICS PASSED! <<<")
	print("==================================================")
	quit(0)
