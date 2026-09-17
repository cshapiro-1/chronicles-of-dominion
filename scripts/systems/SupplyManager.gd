extends Node

var supply_centers: Array[Vector3] = [Vector3.ZERO]
const SUPPLY_RANGE: float = 65.0

func is_in_supply(pos: Vector3) -> bool:
	for center in supply_centers:
		if pos.distance_to(center) <= SUPPLY_RANGE:
			return true
	return false
