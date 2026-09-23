extends "res://scenes/buildings/Building.gd"
class_name Bazaar

func _init() -> void:
	building_id = "bazaar"
	building_name = "Grand Bazaar"
	building_category = "Economic"
	max_health = 900.0
	gold_cost = 200
	wood_cost = 100
	mudbrick_cost = 60
	construction_time = 4.5
	gold_production = 25.0
