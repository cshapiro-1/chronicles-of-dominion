extends "res://scripts/actions/Action.gd"

var target_unit: Node = null
var stop_distance: float = 2.0

func _init(p_unit: Node, p_target: Node, p_stop_dist: float = 2.0) -> void:
	super(p_unit)
	target_unit = p_target
	stop_distance = p_stop_dist

func process(_delta: float) -> void:
	if not is_instance_valid(target_unit):
		is_finished = true
		return
	var u3d = unit as Node3D
	var t3d = target_unit as Node3D
	if not u3d or not t3d:
		is_finished = true
		return
	if u3d.global_position.distance_to(t3d.global_position) <= stop_distance:
		is_finished = true
		return
	if unit.has_method("set_target_destination"):
		unit.set_target_destination(t3d.global_position)
