extends "res://scripts/actions/Action.gd"

var destination: Vector3 = Vector3.ZERO

func _init(p_unit: Node, p_dest: Vector3) -> void:
	super(p_unit)
	destination = p_dest

func start() -> void:
	if unit and unit.has_method("set_target_destination"):
		unit.set_target_destination(destination)

func process(_delta: float) -> void:
	if not unit:
		is_finished = true
		return
	var has_target = unit.get("has_target") if "has_target" in unit else false
	if not has_target:
		is_finished = true
