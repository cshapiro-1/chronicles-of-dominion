extends StaticBody3D

@export var building_name: String = "Building"
@export var max_health: float = 1000.0
@export var team_id: int = 0

var current_health: float = 1000.0

func _ready() -> void:
	current_health = max_health
	EventBus.building_spawned.emit(self)
