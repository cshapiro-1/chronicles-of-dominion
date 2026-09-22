class_name UnitGroupSelectionHandler
extends Node

var groups: Dictionary = {} # group_index (1..9) -> Array of unit instances

func bind_group(index: int, units: Array) -> void:
	groups[index] = units.duplicate()

func recall_group(index: int) -> Array:
	if not groups.has(index):
		return []
	var valid = []
	for u in groups[index]:
		if is_instance_valid(u):
			valid.append(u)
	groups[index] = valid
	return valid
