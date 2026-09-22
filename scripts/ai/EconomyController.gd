class_name AIEconomyController
extends RefCounted

var ai_player: Node = null
var last_harvest_tick: float = 0.0

func _init(p_ai: Node) -> void:
	ai_player = p_ai

func update(delta: float) -> void:
	# Ensure workers are continuously harvesting grain and bronze
	var workers = ai_player.get_tree().get_nodes_in_group("Units").filter(
		func(u): return u.get("team_id") == 1 and u.get("unit_type") == "worker"
	)
	var granary = ai_player.get_tree().get_first_node_in_group("EnemyCitadel")
	for w in workers:
		if not w.current_action:
			var wheat_field = ai_player.get_tree().get_first_node_in_group("ResourceNodes")
			if wheat_field and granary:
				w.execute_action(ActionCollectingResourcesSequentially.new(w, wheat_field, granary))
