extends Node

signal succession_triggered(new_ruler: Dictionary)
signal legitimacy_updated(legitimacy: float)
signal mutiny_erupted(province_name: String)

var current_ruler_name: String = "Sargon I"
var ruler_age: int = 48
var ruler_health: float = 100.0
var legitimacy: float = 85.0 # 0 to 100%

var in_succession_crisis: bool = false
var consolidation_timer: float = 0.0
var consolidation_deadline: float = 45.0 # 45 seconds real-time grace period

var dynasty_lineage: Array[String] = ["Ur-Zababa", "Sargon I"]
var heir_name: String = "Rimush"

func _process(delta: float) -> void:
	if in_succession_crisis:
		consolidation_timer += delta
		var remaining = consolidation_deadline - consolidation_timer
		if remaining <= 0.0:
			_evaluate_consolidation_outcome()

func trigger_ruler_death() -> void:
	var old_ruler = current_ruler_name
	current_ruler_name = heir_name
	heir_name = "Manishtushu" if heir_name == "Rimush" else "Naram-Sin"
	dynasty_lineage.append(current_ruler_name)
	
	# Succession shock
	legitimacy = 30.0 # Drops to dangerous level
	in_succession_crisis = true
	consolidation_timer = 0.0
	
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.post_notification(
			"DYNASTIC SUCCESSION",
			"%s has died! %s ascends the throne. Legitimacy collapsed to %d%%. Consolidate power or face mutiny!" % [
				old_ruler, current_ruler_name, int(legitimacy)
			],
			Color(1.0, 0.4, 0.2)
		)
	succession_triggered.emit({
		"old_ruler": old_ruler,
		"new_ruler": current_ruler_name,
		"legitimacy": legitimacy
	})

func enact_consolidation_edict(edict_type: String) -> bool:
	if not in_succession_crisis:
		var eb = get_node_or_null("/root/EventBus")
		if eb: eb.post_notification("NO CRISIS", "Dynasty is currently stable.", Color(0.8, 0.8, 0.8))
		return false
		
	var eco = get_node_or_null("/root/EconomyManager")
	var pol = get_node_or_null("/root/PoliticsManager")
	var eb = get_node_or_null("/root/EventBus")
	
	match edict_type:
		"purge_rivals":
			# Execute pretenders
			legitimacy = min(100.0, legitimacy + 25.0)
			if pol: pol.adjust_loyalty("nobility", -20)
			if eb:
				eb.post_notification("RIVALS PURGED", "Pretenders executed. Legitimacy +25% (Nobility discontent rises).", Color(0.95, 0.4, 0.2))
			_check_crisis_resolved()
			return true
			
		"treasury_dole":
			# Bribe populace & army
			if eco and eco.resources.get("Gold", 0) < 300:
				if eb: eb.post_notification("INSUFFICIENT GOLD", "Need 300 Gold for Coronation Dole.", Color(1, 0.3, 0.3))
				return false
			if eco: eco.resources["Gold"] -= 300
			legitimacy = min(100.0, legitimacy + 30.0)
			if pol: pol.adjust_loyalty("commoners", 15)
			if eb:
				eb.post_notification("ROYAL DOLE DISTRIBUTED", "Gold disbursed. Legitimacy +30%.", Color(0.4, 0.95, 0.5))
			_check_crisis_resolved()
			return true
			
		"temple_coronation":
			# Priesthood sanction
			if eco and eco.resources.get("Grain", 0) < 400:
				if eb: eb.post_notification("INSUFFICIENT GRAIN", "Need 400 Grain for Temple Feast.", Color(1, 0.3, 0.3))
				return false
			if eco: eco.resources["Grain"] -= 400
			legitimacy = min(100.0, legitimacy + 25.0)
			if pol: pol.adjust_loyalty("priesthood", 20)
			if eb:
				eb.post_notification("DIVINE CORONATION", "High Priesthood blesses reign. Legitimacy +25%.", Color(0.4, 0.8, 1.0))
			_check_crisis_resolved()
			return true
			
	return false

func _check_crisis_resolved() -> void:
	legitimacy_updated.emit(legitimacy)
	if legitimacy >= 70.0:
		in_succession_crisis = false
		consolidation_timer = 0.0
		var eb = get_node_or_null("/root/EventBus")
		if eb:
			eb.post_notification(
				"POWER CONSOLIDATED",
				"The realm bows to %s! Dynastic authority fully secured." % current_ruler_name,
				Color(0.4, 0.95, 0.5)
			)

func _evaluate_consolidation_outcome() -> void:
	in_succession_crisis = false
	if legitimacy < 60.0:
		_trigger_dynastic_mutiny()
	else:
		_check_crisis_resolved()

func _trigger_dynastic_mutiny() -> void:
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.post_notification(
			"DYNASTIC MUTINY ERUPTS!",
			"Failure to consolidate power! Disloyal generals and rebel pretenders rise in arms!",
			Color(1.0, 0.15, 0.15)
		)
	mutiny_erupted.emit("Lagash")
	
	# Spawn rebel host near city
	var world = get_tree().root.get_node_or_null("Main/World")
	if world:
		var unit_scene = load("res://scenes/units/Unit.tscn")
		if unit_scene:
			for i in range(4):
				var u = unit_scene.instantiate()
				u.unit_type = "raider" if i % 2 == 0 else "spearman"
				u.team_id = 1 # Hostile rebel
				u.position = Vector3(randf_range(-12, 12), 0.0, 35.0)
				world.add_child(u)
