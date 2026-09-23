extends "res://scenes/buildings/Building.gd"
class_name ChariotFoundry

func _init() -> void:
	building_id = "chariot_foundry"
	building_name = "War Chariot Foundry"
	building_category = "Military"
	max_health = 1600.0
	gold_cost = 300
	wood_cost = 200
	mudbrick_cost = 80
	construction_time = 5.5
