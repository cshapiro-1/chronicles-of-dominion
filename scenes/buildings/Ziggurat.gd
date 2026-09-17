extends "res://scenes/buildings/Building.gd"

func recruit_unit(unit_type_name: String) -> void:
	var cost = {}
	var tres_path = ""
	
	match unit_type_name:
		"Spearman":
			cost = {"Grain": 50.0, "Bronze": 20.0}
			tres_path = "res://data/units/Spearman.tres"
		"Slinger":
			cost = {"Grain": 40.0, "Timber": 25.0}
			tres_path = "res://data/units/Slinger.tres"
		"Chariot":
			cost = {"Grain": 90.0, "Bronze": 50.0, "Timber": 40.0}
			tres_path = "res://data/units/Chariot.tres"
	
	if EconomyManager.spend_resources(cost):
		var unit_scene = load("res://scenes/units/Unit.tscn")
		var new_unit = unit_scene.instantiate()
		new_unit.unit_data = load(tres_path)
		new_unit.team_id = 0
		
		var spawn_offset = Vector3(randf_range(-3.0, 3.0), 0.0, 12.0 + randf_range(0.0, 3.0))
		var units_node = get_parent().get_node_or_null("Units")
		if not units_node:
			units_node = get_parent()
		units_node.add_child(new_unit)
		new_unit.global_position = global_position + spawn_offset
		
		EventBus.notification_posted.emit("COHORT RECRUITED", "%s detachment mustered at Ziggurat Gate." % new_unit.unit_data.unit_name, Color(0.95, 0.82, 0.35))
	else:
		EventBus.notification_posted.emit("INSUFFICIENT TRIBUTE", "Not enough resources to train %s." % unit_type_name, Color(0.95, 0.25, 0.25))
