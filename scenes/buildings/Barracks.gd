extends Building
class_name Barracks

func _init() -> void:
	building_id = "barracks"
	building_name = "Military Barracks"
	building_category = "Military"
	max_health = 1400.0
	gold_cost = 150
	wood_cost = 80
	mudbrick_cost = 40
	construction_time = 4.5
