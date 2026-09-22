extends "res://scripts/actions/Action.gd"

var target_foundation: Node = null
var build_rate: float = 30.0

func _init(p_unit: Node, p_foundation: Node) -> void:
	super(p_unit)
	target_foundation = p_foundation

func process(delta: float) -> void:
	if not is_instance_valid(target_foundation):
		is_finished = true
		return
		
	var u3d = unit as Node3D
	var f3d = target_foundation as Node3D
	var dist = u3d.global_position.distance_to(f3d.global_position)
	
	if dist > 4.5:
		if unit.has_method("set_target_destination"):
			unit.set_target_destination(f3d.global_position)
	else:
		if "has_target" in unit: unit.set("has_target", false)
		if target_foundation.has_method("apply_construction_progress"):
			target_foundation.apply_construction_progress(build_rate * delta)
		is_finished = true
