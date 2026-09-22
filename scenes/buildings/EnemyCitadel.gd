extends StaticBody3D

@export var citadel_name: String = "CITADEL OF LAGASH"
@export var max_health: float = 2500.0
@export var current_health: float = 2500.0

@onready var hp_label: Label3D = $HPLabel
@onready var flag_mesh: MeshInstance3D = $FortressModel/Banner

var is_destroyed: bool = false
var spawn_timer: float = 0.0

func _ready() -> void:
	add_to_group("EnemyBuildings")
	add_to_group("Destructible")
	current_health = max_health
	_update_hp_display()
	MeshFactory.apply_pbr_to_tree(self)

func _process(delta: float) -> void:
	if is_destroyed:
		return
	
	# Periodic garrison patrol spawn
	spawn_timer += delta
	if spawn_timer >= 24.0:
		spawn_timer = 0.0
		_spawn_garrison_guard()

func _spawn_garrison_guard() -> void:
	var unit_scene = load("res://scenes/units/Unit.tscn")
	var raider_data = load("res://data/units/Raider.tres")
	if unit_scene and raider_data:
		var guard = unit_scene.instantiate()
		guard.unit_data = raider_data
		guard.team_id = 1
		get_parent().add_child(guard)
		guard.global_position = global_position + Vector3(randf_range(-6.0, 6.0), 0.0, randf_range(4.0, 8.0))
		guard.move_to_position(global_position + Vector3(0, 0, 12))

func take_damage(amount: float) -> void:
	if is_destroyed:
		return
	current_health = max(0.0, current_health - amount)
	_update_hp_display()
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", 0.2, 0.05)
	tween.tween_property(self, "position:y", 0.0, 0.08)
	
	if current_health <= 0.0:
		_on_citadel_fallen()

func _update_hp_display() -> void:
	if hp_label:
		var pct = int((current_health / max_health) * 100.0)
		hp_label.text = "%s\nFORTIFICATION: %d / %d (%d%%)" % [citadel_name, int(current_health), int(max_health), pct]
		if pct < 30:
			hp_label.modulate = Color(1.0, 0.25, 0.25)
		elif pct < 60:
			hp_label.modulate = Color(1.0, 0.8, 0.3)
		else:
			hp_label.modulate = Color(1.0, 0.95, 0.7)

func _on_citadel_fallen() -> void:
	is_destroyed = true
	if hp_label:
		hp_label.text = "⚔ CITADEL FALLEN ⚔"
		hp_label.modulate = Color(1.0, 0.2, 0.2)
	
	EventBus.post_notification("SOVEREIGN CONQUEST", "%s has been breached by our legions!" % citadel_name, Color(1.0, 0.85, 0.3))
	
	var spoils = {
		"Gold": 1500,
		"Bronze": 600,
		"Grain": 800,
		"TributeGrain": 50,
		"TributeBronze": 30,
		"TributeGold": 40
	}
	
	EventBus.conquest_victory_triggered.emit(citadel_name, spoils)
