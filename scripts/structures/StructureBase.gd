class_name StructureBase
extends StaticBody3D

@export var structure_name: String = "Barracks"
@export var team_id: int = 0
@export var max_health: float = 600.0

@onready var trait_selection: TraitSelection = $TraitSelection
@onready var trait_health: TraitHealthBar = $TraitHealthBar
@onready var trait_prod: TraitProductionQueue = $TraitProductionQueue
@onready var trait_rally: TraitRallyPoint = $TraitRallyPoint

func _ready() -> void:
	add_to_group("Structures")
	if trait_prod:
		trait_prod.item_completed.connect(_on_unit_completed)

func _process(delta: float) -> void:
	if trait_prod:
		trait_prod.process_queue(delta)

func _on_unit_completed(unit_type: String) -> void:
	var unit_scene = load("res://scenes/units/Unit.tscn")
	if not unit_scene:
		return
	var u = unit_scene.instantiate()
	u.unit_type = unit_type
	u.team_id = team_id
	var spawn_pos = global_position + Vector3(0, 0, 4.0)
	u.position = spawn_pos
	get_tree().root.get_node("Main/World").add_child(u)
	
	if trait_rally:
		u.set_target_destination(trait_rally.rally_destination)
	EventBus.post_notification("PRODUCTION COMPLETE", "%s trained at %s" % [unit_type.capitalize(), structure_name], Color(0.48, 0.95, 0.52))

func take_damage(dmg: float) -> void:
	if trait_health:
		trait_health.current_health -= dmg
		if trait_health.current_health <= 0:
			queue_free()
