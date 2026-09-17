extends Resource
class_name BuildingData

@export var building_name: String = "Ziggurat of Ur-Kish"
@export var max_health: float = 2500.0
@export var cost: Dictionary = { "Stone": 500.0, "Timber": 200.0 }
@export var footprint_size: Vector2 = Vector2(8, 8)
@export var production_yield: Dictionary = { "Gold": 10.0 }
