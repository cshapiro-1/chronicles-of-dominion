extends Resource
class_name UnitData

@export var unit_name: String = "Bronze Spearman"
@export var max_health: float = 140.0
@export var damage: float = 22.0
@export var attack_range: float = 2.4
@export var attack_speed: float = 1.1
@export var move_speed: float = 5.2
@export var armor: float = 6.0
@export var cost: Dictionary = { "Grain": 50.0, "Bronze": 20.0 }
@export var mesh_color: Color = Color(0.85, 0.65, 0.25)
@export var is_ranged: bool = false
@export var projectile_speed: float = 25.0
