extends "res://scripts/actions/Action.gd"

const AttackingWhileInRange = preload("res://scripts/actions/AttackingWhileInRange.gd")

var current_target: Node = null
var sub_attack_action = null
var vision_range: float = 24.0

func process(delta: float) -> void:
	if is_instance_valid(current_target):
		if not sub_attack_action:
			sub_attack_action = AttackingWhileInRange.new(unit, current_target)
		sub_attack_action.process(delta)
		if sub_attack_action.is_finished:
			current_target = null
			sub_attack_action = null
		return
		
	var my_team = unit.get("team_id") if "team_id" in unit else 0
	var units = unit.get_tree().get_nodes_in_group("Units")
	var u3d = unit as Node3D
	var best_dist = vision_range
	var best_enemy: Node = null
	
	for e in units:
		if is_instance_valid(e) and e != unit:
			var e_team = e.get("team_id") if "team_id" in e else 0
			if e_team != my_team:
				var dist = u3d.global_position.distance_to(e.global_position)
				if dist < best_dist:
					best_dist = dist
					best_enemy = e
					
	if best_enemy:
		current_target = best_enemy
		sub_attack_action = AttackingWhileInRange.new(unit, current_target)
