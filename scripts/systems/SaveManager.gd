extends Node

const SAVE_PATH = "user://chronicles_save.json"

func save_game() -> bool:
	var save_dict = {
		"version": "1.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"economy": {
			"resources": EconomyManager.resources,
			"deltas": EconomyManager.deltas
		},
		"population": {
			"total": PopulationManager.total_population,
			"housing": PopulationManager.max_housing,
			"hope": PopulationManager.hope,
			"discontent": PopulationManager.discontent,
			"conscription_pool": PopulationManager.conscription_pool
		},
		"politics": {
			"priesthood": PoliticsManager.priesthood_loyalty,
			"nobility": PoliticsManager.nobility_loyalty,
			"commoners": PoliticsManager.commoners_loyalty
		},
		"tech": {
			"epoch": TechManager.current_epoch if TechManager else 1,
			"researched": TechManager.researched_techs if TechManager else []
		},
		"units": [],
		"buildings": []
	}
	
	# Serialize units
	for u in get_tree().get_nodes_in_group("Units"):
		if is_instance_valid(u):
			save_dict["units"].append({
				"type": u.get("unit_type"),
				"team_id": u.get("team_id"),
				"hp": u.get("current_hp"),
				"pos_x": u.global_position.x,
				"pos_y": u.global_position.y,
				"pos_z": u.global_position.z,
				"formation": u.get("active_formation")
			})
			
	# Serialize buildings
	for b in get_tree().get_nodes_in_group("Buildings"):
		if is_instance_valid(b):
			save_dict["buildings"].append({
				"id": b.get("building_id"),
				"name": b.get("building_name"),
				"team_id": b.get("team_id"),
				"hp": b.get("current_health"),
				"state": b.get("state"),
				"pos_x": b.global_position.x,
				"pos_y": b.global_position.y,
				"pos_z": b.global_position.z
			})
			
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		EventBus.post_notification("SAVE FAILED", "Could not open save file on disk.", Color(1, 0.3, 0.3))
		return false
		
	var json_str = JSON.stringify(save_dict, "\t")
	file.store_string(json_str)
	file.close()
	
	EventBus.post_notification("CHRONICLE SAVED", "Imperial state recorded to %s" % SAVE_PATH, Color(0.4, 0.95, 0.5))
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		EventBus.post_notification("LOAD FAILED", "No previous chronicle save found.", Color(1, 0.3, 0.3))
		return false
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
		
	var json_str = file.get_as_text()
	file.close()
	
	var parse_res = JSON.parse_string(json_str)
	if typeof(parse_res) != TYPE_DICTIONARY:
		return false
		
	var data: Dictionary = parse_res
	
	# Restore economy
	if data.has("economy"):
		EconomyManager.resources = data["economy"].get("resources", EconomyManager.resources)
		EconomyManager.deltas = data["economy"].get("deltas", EconomyManager.deltas)
		EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)
		
	# Restore population
	if data.has("population"):
		var p = data["population"]
		PopulationManager.total_population = p.get("total", PopulationManager.total_population)
		PopulationManager.max_housing = p.get("housing", PopulationManager.max_housing)
		PopulationManager.hope = p.get("hope", PopulationManager.hope)
		PopulationManager.discontent = p.get("discontent", PopulationManager.discontent)
		PopulationManager.conscription_pool = p.get("conscription_pool", PopulationManager.conscription_pool)
		
	# Restore politics
	if data.has("politics"):
		var pol = data["politics"]
		PoliticsManager.priesthood_loyalty = pol.get("priesthood", 50.0)
		PoliticsManager.nobility_loyalty = pol.get("nobility", 50.0)
		PoliticsManager.commoners_loyalty = pol.get("commoners", 50.0)
		
	# Restore tech
	if data.has("tech") and TechManager:
		TechManager.current_epoch = data["tech"].get("epoch", TechManager.Epoch.BRONZE)
		TechManager.researched_techs = Array(data["tech"].get("researched", []), TYPE_STRING, &"", null)
		
	EventBus.post_notification("CHRONICLE RESTORED", "Historical timeline successfully loaded.", Color(0.95, 0.85, 0.35))
	return true
