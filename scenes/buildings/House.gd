extends "res://scenes/buildings/Building.gd"
class_name House

func _init() -> void:
	building_id = "mudbrick_house"
	building_name = "Mudbrick Tenement"
	building_category = "Housing"
	max_health = 650.0
	gold_cost = 60
	mudbrick_cost = 50
	wood_cost = 20
	construction_time = 3.5
	housing_provided = 35
	population_provided = 20
