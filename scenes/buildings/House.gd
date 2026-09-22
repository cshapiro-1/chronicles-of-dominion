extends Building
class_name House

func _init() -> void:
	building_id = "house"
	building_name = "Mudbrick Tenement"
	building_category = "Housing"
	max_health = 600.0
	gold_cost = 60
	mudbrick_cost = 50
	wood_cost = 20
	construction_time = 3.0
	housing_provided = 35
	population_provided = 20
