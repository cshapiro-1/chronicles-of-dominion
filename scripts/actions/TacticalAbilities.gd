extends RefCounted
class_name TacticalAbilities

static func rally_line(units: Array) -> int:
	var count = 0
	for u in units:
		if is_instance_valid(u) and u.has_method("activate_rally"):
			if u.activate_rally():
				count += 1
	if count > 0:
		var eb = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
		if eb: eb.post_notification("TACTICAL ABILITY", "Rally the Line! %d cohorts restored discipline (+25 Morale, +20 HP)." % count, Color(1.0, 0.85, 0.3))
		var am = Engine.get_main_loop().root.get_node_or_null("/root/AudioManager")
		if am: am.play_sfx("order")
	return count

static func shield_brace(units: Array) -> int:
	var count = 0
	for u in units:
		if is_instance_valid(u) and u.has_method("activate_shield_brace"):
			if u.activate_shield_brace():
				count += 1
	if count > 0:
		var eb = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
		if eb: eb.post_notification("TACTICAL ABILITY", "Shield Wall Braced! %d infantry cohorts locked shields (+50%% Armor)." % count, Color(0.4, 0.85, 1.0))
		var am = Engine.get_main_loop().root.get_node_or_null("/root/AudioManager")
		if am: am.play_sfx("build")
	return count

static func chariot_trample(units: Array) -> int:
	var count = 0
	for u in units:
		if is_instance_valid(u) and u.has_method("activate_chariot_trample"):
			if u.activate_chariot_trample():
				count += 1
	if count > 0:
		var eb = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
		if eb: eb.post_notification("TACTICAL ABILITY", "Chariot Shock Trample! %d chariot divisions surging forward (1.6x Speed, Trample Damage)." % count, Color(1.0, 0.4, 0.2))
		var am = Engine.get_main_loop().root.get_node_or_null("/root/AudioManager")
		if am: am.play_sfx("attack")
	return count

static func arrow_volley(units: Array, target_pos: Vector3 = Vector3.ZERO) -> int:
	var count = 0
	for u in units:
		if is_instance_valid(u) and u.has_method("activate_arrow_volley"):
			if u.activate_arrow_volley(target_pos):
				count += 1
	if count > 0:
		var eb = Engine.get_main_loop().root.get_node_or_null("/root/EventBus")
		if eb: eb.post_notification("TACTICAL ABILITY", "Arrow Rain Volley! %d missile cohorts loosed massed barrage." % count, Color(0.9, 0.75, 0.2))
		var am = Engine.get_main_loop().root.get_node_or_null("/root/AudioManager")
		if am: am.play_sfx("attack")
	return count
