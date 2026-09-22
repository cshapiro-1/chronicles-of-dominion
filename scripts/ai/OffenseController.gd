class_name AIOffenseController
extends RefCounted

var ai_player: Node = null
var muster_timer: float = 0.0
var attack_interval: float = 45.0 # Launch attack wave every 45s

func _init(p_ai: Node) -> void:
	ai_player = p_ai

func update(delta: float) -> void:
	muster_timer += delta
	if muster_timer >= attack_interval:
		muster_timer = 0.0
		_launch_assault_wave()

func _launch_assault_wave() -> void:
	var strike_force = ai_player.get_tree().get_nodes_in_group("Units").filter(
		func(u): return u.get("team_id") == 1 and u.get("unit_type") != "worker"
	)
	if strike_force.is_empty():
		return
		
	var player_citadel = ai_player.get_tree().get_first_node_in_group("CapitalCity")
	var target_pos = player_citadel.global_position if player_citadel else Vector3.ZERO
	
	for unit in strike_force:
		unit.execute_action(ActionAutoAttacking.new(unit))
		var move_trait = unit.get_node_or_null("TraitMovement") as TraitMovement
		if move_trait:
			move_trait.move_to(target_pos + Vector3(randf_range(-6, 6), 0, randf_range(-6, 6)))
			
	EventBus.post_notification("WAR HORN", "Enemy assault column marches upon Ur-Kish!", Color(1.0, 0.25, 0.25))
