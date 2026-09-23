class_name AIOffenseController
extends RefCounted

var ai_player: Node = null
var muster_timer: float = 0.0
var attack_interval: float = 35.0 # Launch attack wave every 35s
var wave_count: int = 0

func _init(p_ai: Node) -> void:
	ai_player = p_ai

func update(delta: float) -> void:
	muster_timer += delta
	if muster_timer >= attack_interval:
		muster_timer = 0.0
		wave_count += 1
		_spawn_and_launch_assault_wave()

func _spawn_and_launch_assault_wave() -> void:
	var tree = ai_player.get_tree()
	if not tree: return
	var world = tree.root.get_node_or_null("Main/World")
	if not world: return
	
	var unit_scene = load("res://scenes/units/Unit.tscn")
	if not unit_scene: return
	
	# Determine wave composition based on wave_count
	var army_size = min(3 + wave_count * 2, 10)
	var spawn_origin = Vector3(randf_range(-15.0, 15.0), 0.0, 50.0)
	
	var strike_force = []
	for i in range(army_size):
		var u = unit_scene.instantiate()
		u.unit_type = "chariot" if (i == 0 and wave_count >= 2) else ("slinger" if i % 2 == 1 else "raider")
		u.team_id = 1
		u.position = spawn_origin + Vector3((i % 3 - 1) * 3.5, 0.0, (i / 3) * 3.5)
		world.add_child(u)
		strike_force.append(u)
		
	# Find primary target: player buildings or central Ziggurat
	var player_buildings = tree.get_nodes_in_group("PlayerBuildings")
	var target_pos = Vector3(0.0, 0.0, 0.0)
	if not player_buildings.is_empty():
		var random_b = player_buildings.pick_random()
		if is_instance_valid(random_b):
			target_pos = random_b.global_position
			
	# Order strike force to march upon target
	for unit in strike_force:
		if is_instance_valid(unit) and unit.has_method("set_target_destination"):
			unit.set_target_destination(target_pos + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3)))
			
	EventBus.post_notification(
		"HOSTILE INCURSION",
		"Nomad Warband (Wave %d - %d Cohorts) attacking the province!" % [wave_count, army_size],
		Color(1.0, 0.25, 0.25)
	)
