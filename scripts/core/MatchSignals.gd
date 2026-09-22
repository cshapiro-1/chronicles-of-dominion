extends Node

# Targeting and selection signals
signal terrain_targeted(position: Vector3, order_type: int)
signal unit_targeted(target_unit: Node, order_type: int)
signal selection_changed(selected_units: Array)
signal unit_spawned(unit: Node)
signal unit_destroyed(unit: Node)
signal structure_placed(structure_type: String, position: Vector3)
signal rally_point_updated(structure: Node, target_pos: Vector3)
signal production_started(structure: Node, unit_type: String, duration: float)
signal production_finished(structure: Node, unit_type: String)
