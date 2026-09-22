extends "res://scripts/actions/Action.gd"

var target_unit: Node = null
var attack_range: float = 4.0
var attack_damage: float = 15.0
var attack_cooldown: float = 1.0
var last_attack_time: float = -10.0

func _init(p_unit: Node, p_target: Node) -> void:
	super(p_unit)
	target_unit = p_target

func process(delta: float) -> void:
	if not is_instance_valid(target_unit):
		is_finished = true
		return
		
	var u3d = unit as Node3D
	var t3d = target_unit as Node3D
	if not u3d or not t3d:
		is_finished = true
		return
		
	var dist = u3d.global_position.distance_to(t3d.global_position)
	
	if dist > attack_range:
		if unit.has_method("set_target_destination"):
			unit.set_target_destination(t3d.global_position)
	else:
		if "has_target" in unit:
			unit.set("has_target", false)
		var now = Time.get_ticks_msec() / 1000.0
		if now - last_attack_time >= attack_cooldown:
			last_attack_time = now
			if target_unit.has_method("take_damage"):
				target_unit.take_damage(attack_damage)
