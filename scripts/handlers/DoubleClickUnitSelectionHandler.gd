class_name DoubleClickUnitSelectionHandler
extends Node

var last_clicked_unit: Node = null
var last_click_time: float = -1.0
const DOUBLE_CLICK_TIME: float = 0.35

func handle_unit_clicked(unit: Node) -> Array:
	var now = Time.get_ticks_msec() / 1000.0
	var is_double = (unit == last_clicked_unit) and (now - last_click_time <= DOUBLE_CLICK_TIME)
	last_clicked_unit = unit
	last_click_time = now
	
	if is_double:
		var unit_type = unit.get("unit_type") if "unit_type" in unit else ""
		var all_same = []
		var units = unit.get_tree().get_nodes_in_group("Units")
		for u in units:
			if is_instance_valid(u) and u.get("unit_type") == unit_type:
				all_same.append(u)
		return all_same
	return [unit]
