extends Node

var supply_centers: Array[Vector3] = []
var mobile_supply_trains: Array[Node3D] = []

const BASE_GRANARY_RANGE: float = 75.0
const BAGGAGE_TRAIN_RANGE: float = 45.0

var supply_check_timer: float = 0.0

func _process(delta: float) -> void:
	supply_check_timer += delta
	if supply_check_timer >= 1.5:
		supply_check_timer = 0.0
		_evaluate_unit_supply()

func register_granary(pos: Vector3) -> void:
	if not pos in supply_centers:
		supply_centers.append(pos)

func unregister_granary(pos: Vector3) -> void:
	supply_centers.erase(pos)

func register_baggage_train(unit: Node3D) -> void:
	if not unit in mobile_supply_trains:
		mobile_supply_trains.append(unit)

func unregister_baggage_train(unit: Node3D) -> void:
	mobile_supply_trains.erase(unit)

func is_in_supply(pos: Vector3) -> bool:
	# 1. Check fixed Granary / City radii
	for center in supply_centers:
		if pos.distance_to(center) <= BASE_GRANARY_RANGE:
			return true
			
	# 2. Check mobile Ox-Cart Baggage Trains
	for train in mobile_supply_trains:
		if is_instance_valid(train) and pos.distance_to(train.global_position) <= BAGGAGE_TRAIN_RANGE:
			return true
			
	return false

func _evaluate_unit_supply() -> void:
	var units = get_tree().get_nodes_in_group("Units")
	var unsupplied_count = 0
	
	for u in units:
		if not is_instance_valid(u) or u.get("team_id") != 0:
			continue
			
		var supplied = is_in_supply(u.global_position)
		if not supplied:
			unsupplied_count += 1
			# Apply hunger attrition: -1.5 HP per tick
			if u.has_method("take_damage"):
				u.take_damage(2.25, Vector3.ZERO, false)
			u.set("is_starving", true)
		else:
			u.set("is_starving", false)
			
	if unsupplied_count > 0 and randf() < 0.2:
		EventBus.post_notification(
			"SUPPLY SEVERED",
			"%d cohorts beyond granary supply lines are suffering hunger attrition!" % unsupplied_count,
			Color(1.0, 0.45, 0.2)
		)
