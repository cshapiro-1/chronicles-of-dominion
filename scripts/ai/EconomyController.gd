class_name AIEconomyController
extends RefCounted

const ActionCollectingResourcesSequentially = preload("res://scripts/actions/CollectingResourcesSequentially.gd")

var ai_player: Node = null
var last_harvest_tick: float = 0.0

func _init(p_ai: Node) -> void:
	ai_player = p_ai

func update(_delta: float) -> void:
	if not ai_player or not is_instance_valid(ai_player):
		return
	var tree = ai_player.get_tree()
	if not tree:
		return
		
	# Ensure workers are continuously harvesting grain and bronze
	var workers = tree.get_nodes_in_group("Units").filter(
		func(u): return is_instance_valid(u) and u.get("team_id") == 1 and u.get("unit_type") == "worker"
	)
	var granary = tree.get_first_node_in_group("EnemyCitadel")
	for w in workers:
		if is_instance_valid(w) and w.get("current_action") == null:
			var wheat_field = tree.get_first_node_in_group("ResourceNodes")
			if wheat_field and granary and w.has_method("execute_action"):
				w.execute_action(ActionCollectingResourcesSequentially.new(w, wheat_field, granary))
