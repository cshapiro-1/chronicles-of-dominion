extends StaticBody3D
class_name Building

enum State {
	GHOST,
	UNDER_CONSTRUCTION,
	COMPLETED,
	DAMAGED,
	DESTROYED
}

@export var building_id: String = "building_base"
@export var building_name: String = "City Structure"
@export var building_category: String = "Economic" # "Economic", "Housing", "Military", "Religious"
@export var max_health: float = 800.0
@export var team_id: int = 0
@export var gold_cost: int = 100
@export var wood_cost: int = 50
@export var mudbrick_cost: int = 50
@export var construction_time: float = 4.0
@export var grain_production: float = 0.0
@export var gold_production: float = 0.0
@export var housing_provided: int = 0
@export var population_provided: int = 0

var current_health: float = 800.0
var construction_progress: float = 0.0
var state: State = State.COMPLETED
var rally_point: Vector3 = Vector3.ZERO
var is_selected: bool = false

@onready var model_root: Node3D = get_node_or_null("ModelRoot")
@onready var scaffolding: Node3D = get_node_or_null("Scaffolding")
@onready var hp_label: Label3D = get_node_or_null("HPBar")
@onready var selection_ring: MeshInstance3D = get_node_or_null("SelectionRing")

func _ready() -> void:
	add_to_group("Buildings")
	if team_id == 0:
		add_to_group("PlayerBuildings")
	else:
		add_to_group("EnemyBuildings")
		
	current_health = max_health
	if rally_point == Vector3.ZERO:
		rally_point = global_position + Vector3(0, 0, 10.0)
		
	if selection_ring:
		selection_ring.visible = false
		
	_init_visual_state()
	update_status_display()
	var eb = get_node_or_null("/root/EventBus")
	if eb: eb.building_spawned.emit(self)

func _process(delta: float) -> void:
	if state == State.UNDER_CONSTRUCTION:
		construction_progress += delta / max(0.1, construction_time)
		current_health = max_health * clamp(construction_progress, 0.1, 1.0)
		update_status_display()
		if construction_progress >= 1.0:
			complete_construction()

func _init_visual_state() -> void:
	if state == State.UNDER_CONSTRUCTION:
		if model_root: model_root.visible = false
		if scaffolding: scaffolding.visible = true
	else:
		if model_root: model_root.visible = true
		if scaffolding: scaffolding.visible = false

func start_construction() -> void:
	state = State.UNDER_CONSTRUCTION
	construction_progress = 0.0
	current_health = max_health * 0.1
	_init_visual_state()
	update_status_display()

func complete_construction() -> void:
	state = State.COMPLETED
	construction_progress = 1.0
	current_health = max_health
	_init_visual_state()
	update_status_display()
	
	var eco = get_node_or_null("/root/EconomyManager")
	var pop = get_node_or_null("/root/PopulationManager")
	var eb = get_node_or_null("/root/EventBus")
	
	# 1. Apply economic production deltas
	if eco:
		if grain_production > 0:
			eco.deltas["Grain"] = eco.deltas.get("Grain", 0.0) + grain_production
		if gold_production > 0:
			eco.deltas["Gold"] = eco.deltas.get("Gold", 0.0) + gold_production
		if eb: eb.economy_updated.emit(eco.resources, eco.deltas)
	
	# 2. Apply population and housing
	if pop:
		if housing_provided > 0:
			pop.add_urban_housing(int(housing_provided / 35.0) if housing_provided >= 35 else 1)
		elif population_provided > 0:
			pop.modify_population(population_provided)
		
	# 3. Notify World to update NavMesh around this new structure
	var world = get_tree().root.get_node_or_null("Main/World")
	if world and world.has_method("notify_structure_built"):
		world.notify_structure_built(self)
		
	if eb:
		eb.post_notification(
			"CONSTRUCTION COMPLETE",
			"%s fully erected." % building_name,
			Color(0.4, 0.95, 0.5)
		)

func take_damage(amount: float, _attacker_pos: Vector3 = Vector3.ZERO, _is_projectile: bool = false) -> void:
	current_health = max(0.0, current_health - amount)
	update_status_display()
	
	if current_health <= max_health * 0.4 and state == State.COMPLETED:
		state = State.DAMAGED
		
	# Hit flash
	if model_root:
		var tw = create_tween()
		tw.tween_property(model_root, "scale", Vector3(1.03, 0.97, 1.03), 0.06)
		tw.tween_property(model_root, "scale", Vector3(1.0, 1.0, 1.0), 0.08)
		
	if current_health <= 0.0:
		_destroy()

func _destroy() -> void:
	state = State.DESTROYED
	
	var eco = get_node_or_null("/root/EconomyManager")
	var eb = get_node_or_null("/root/EventBus")
	
	# Reclaim production deltas
	if eco:
		if grain_production > 0:
			eco.deltas["Grain"] = max(0.0, eco.deltas.get("Grain", 0.0) - grain_production)
		if gold_production > 0:
			eco.deltas["Gold"] = max(0.0, eco.deltas.get("Gold", 0.0) - gold_production)
		if eb: eb.economy_updated.emit(eco.resources, eco.deltas)
	
	if eb:
		eb.post_notification(
			"STRUCTURE DESTROYED",
			"%s has collapsed!" % building_name,
			Color(1.0, 0.25, 0.25)
		)
	
	var world = get_tree().root.get_node_or_null("Main/World")
	if world and world.has_method("notify_structure_destroyed"):
		world.notify_structure_destroyed(self)
		
	queue_free()

func select() -> void:
	is_selected = true
	if selection_ring:
		selection_ring.visible = true

func deselect() -> void:
	is_selected = false
	if selection_ring:
		selection_ring.visible = false

func set_selected(val: bool) -> void:
	if val: select()
	else: deselect()

func set_rally_point(pos: Vector3) -> void:
	rally_point = Vector3(pos.x, 0.0, pos.z)
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.post_notification(
			"RALLY POINT SET",
			"New recruits will muster at (%d, %d)." % [int(rally_point.x), int(rally_point.z)],
			Color(0.85, 0.75, 0.35)
		)

func recruit_unit(unit_type: String) -> Node3D:
	var eb = get_node_or_null("/root/EventBus")
	var eco = get_node_or_null("/root/EconomyManager")
	var pop = get_node_or_null("/root/PopulationManager")
	
	if state != State.COMPLETED:
		if eb: eb.post_notification("CANNOT RECRUIT", "Structure is still under construction.", Color(1.0, 0.3, 0.3))
		return null
		
	# Check cost
	var gold_req = 50
	var pop_req = 1
	var type_l = unit_type.to_lower()
	if "chariot" in type_l:
		gold_req = 120
		pop_req = 2
	elif "slinger" in type_l or "archer" in type_l:
		gold_req = 60
		pop_req = 1
	else:
		gold_req = 40
		pop_req = 1
		
	if eco and eco.resources.get("Gold", 0) < gold_req:
		if eb: eb.post_notification("INSUFFICIENT GOLD", "Need %d Gold to recruit %s." % [gold_req, unit_type], Color(1.0, 0.3, 0.3))
		return null
	if pop and pop.conscription_pool < pop_req:
		if eb: eb.post_notification("NO MANPOWER", "Not enough recruits in conscription pool.", Color(1.0, 0.3, 0.3))
		return null
		
	if eco:
		eco.resources["Gold"] -= gold_req
	if pop:
		pop.conscription_pool -= pop_req
	if eb and eco:
		eb.economy_updated.emit(eco.resources, eco.deltas)
	
	var unit_scene = load("res://scenes/units/Unit.tscn")
	if not unit_scene: return null
	
	var unit_inst = unit_scene.instantiate()
	unit_inst.unit_type = unit_type
	unit_inst.team_id = team_id
	
	# Spawn at structure front
	var spawn_pos = global_position + Vector3(randf_range(-2.0, 2.0), 0.0, 6.0)
	unit_inst.position = spawn_pos
	
	var world = get_tree().root.get_node_or_null("Main/World")
	if world:
		world.add_child(unit_inst)
	else:
		get_parent().add_child(unit_inst)
		
	# Issue automatic move order to rally point
	if rally_point.distance_to(spawn_pos) > 2.0:
		unit_inst.set_target_destination(rally_point)
		
	if eb:
		eb.post_notification(
			"COHORT MUSTERED",
			"%s mustered and marching to rally point." % unit_type.capitalize(),
			Color(0.4, 0.95, 0.5)
		)
	return unit_inst

func update_status_display() -> void:
	if not hp_label:
		return
	if state == State.UNDER_CONSTRUCTION:
		hp_label.text = "BUILDING... %d%%" % int(construction_progress * 100.0)
		hp_label.modulate = Color(0.95, 0.85, 0.25)
	else:
		hp_label.text = "%s\n%d / %d" % [building_name, int(current_health), int(max_health)]
		var ratio = current_health / max(1.0, max_health)
		if ratio > 0.6:
			hp_label.modulate = Color(0.4, 0.95, 0.4)
		elif ratio > 0.3:
			hp_label.modulate = Color(1.0, 0.85, 0.3)
		else:
			hp_label.modulate = Color(1.0, 0.25, 0.25)
