extends Node

signal economy_updated(resources: Dictionary, deltas: Dictionary)
signal population_updated(population: int, hope: float, discontent: float)
signal estates_updated(priesthood: float, nobility: float, commoners: float)
signal units_selected(units: Array)
signal unit_spawned(unit: Node)
signal unit_killed(unit: Node)
signal building_spawned(building: Node)
signal crisis_triggered(crisis_data: Resource)
signal crisis_resolved(crisis_data: Resource, option_index: int)
signal game_state_changed(new_state: int)
signal notification_posted(title: String, message: String, color: Color)
signal conquest_victory_triggered(citadel_name: String, spoils: Dictionary)
signal sovereign_resolution_chosen(resolution_type: String)
signal minimap_pan_requested(world_pos: Vector3)

func post_notification(title: String, message: String, color: Color = Color.WHITE) -> void:
	notification_posted.emit(title, message, color)

