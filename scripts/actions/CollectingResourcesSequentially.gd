extends "res://scripts/actions/Action.gd"

var resource_node: Node = null
var dropoff_structure: Node = null
var current_cargo: int = 0
var max_cargo: int = 15
var is_returning: bool = false
var harvest_timer: float = 0.0

func _init(p_unit: Node, p_res: Node, p_dropoff: Node) -> void:
	super(p_unit)
	resource_node = p_res
	dropoff_structure = p_dropoff

func process(delta: float) -> void:
	var u3d = unit as Node3D
	if not u3d:
		is_finished = true
		return
		
	if not is_returning:
		if not is_instance_valid(resource_node):
			is_finished = true
			return
		var dist = u3d.global_position.distance_to(resource_node.global_position)
		if dist > 2.5:
			if unit.has_method("set_target_destination"):
				unit.set_target_destination(resource_node.global_position)
		else:
			if "has_target" in unit: unit.set("has_target", false)
			harvest_timer += delta
			if harvest_timer >= 2.0:
				harvest_timer = 0.0
				current_cargo = max_cargo
				is_returning = true
	else:
		if not is_instance_valid(dropoff_structure):
			dropoff_structure = unit.get_tree().get_first_node_in_group("CapitalCity")
		if not dropoff_structure:
			is_finished = true
			return
		var dist = u3d.global_position.distance_to(dropoff_structure.global_position)
		if dist > 3.5:
			if unit.has_method("set_target_destination"):
				unit.set_target_destination(dropoff_structure.global_position)
		else:
			EconomyManager.resources["Grain"] = EconomyManager.resources.get("Grain", 0) + current_cargo
			EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)
			current_cargo = 0
			is_returning = false
