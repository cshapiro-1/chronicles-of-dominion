extends "res://scenes/buildings/Building.gd"
class_name Granary

func _init() -> void:
	building_id = "granary"
	building_name = "Royal Granary"
	building_category = "Economic"
	max_health = 1000.0
	gold_cost = 100
	mudbrick_cost = 120
	wood_cost = 30
	construction_time = 4.0
	grain_production = 15.0
