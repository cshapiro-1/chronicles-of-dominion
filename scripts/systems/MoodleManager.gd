extends Node

signal moodle_added(moodle_id: String, tier: int)
signal moodle_updated(moodle_id: String, tier: int, progress: float)
signal moodle_removed(moodle_id: String)
signal moodle_escalated(moodle_id: String, tier: int)
signal disaster_triggered(moodle_id: String, disaster_name: String)

# Moodle Definitions & Thresholds
const MOODLE_DEFS = {
	"famine": {
		"title": "Famine",
		"icon": "🌾",
		"tier_names": ["Grain Shortage", "Food Scarcity", "Severe Starvation", "Famine Riots"],
		"tier_colors": [Color(0.85, 0.75, 0.25), Color(0.95, 0.55, 0.2), Color(0.95, 0.25, 0.2), Color(0.8, 0.1, 0.3)],
		"descriptions": [
			"Grain stores running dangerously low. Minor discontent simmering.",
			"Food is scarce. Commoners grow anxious and worker stamina falters (-15% Output).",
			"Widespread starvation stalks the realm. Commoners dying, health decay (-30% Output).",
			"Desperate mobs storm the streets! Bread riots and granary sackings imminent!"
		],
		"remedy": "Construct Granaries, trade for Grain at the Bazaar, or sacrifice to the Harvest Gods.",
		"fester_rate": 0.08, # Progress per second when condition active
		"recovery_rate": 0.15 # Recovery per second when condition resolved
	},
	"unrest": {
		"title": "Popular Unrest",
		"icon": "⚖️",
		"tier_names": ["Simmering Grievances", "Open Dissent", "Sedition & Agitation", "Popular Uprising"],
		"tier_colors": [Color(0.85, 0.75, 0.25), Color(0.95, 0.55, 0.2), Color(0.95, 0.25, 0.2), Color(0.8, 0.1, 0.3)],
		"descriptions": [
			"Commoners mutter over taxes and burdens. Public order begins to slip.",
			"Protests erupt in market squares. Tax collection impaired (-20% Gold).",
			"Agitators preach open defiance. Peasant work stoppages threaten the economy.",
			"The populace has taken up arms! A general strike and city riots are erupting!"
		],
		"remedy": "Lower provincial tax rates, disburse Royal Dole (Gold), or build Tenements/Bazaars.",
		"fester_rate": 0.07,
		"recovery_rate": 0.14
	},
	"mutiny": {
		"title": "Military Disaffection",
		"icon": "⚔️",
		"tier_names": ["Soldier Grumbles", "Discipline Decay", "Officer Defiance", "Armed Mutiny"],
		"tier_colors": [Color(0.85, 0.75, 0.25), Color(0.95, 0.55, 0.2), Color(0.95, 0.25, 0.2), Color(0.8, 0.1, 0.3)],
		"descriptions": [
			"Troops murmur over dynastic legitimacy and supply line delays.",
			"Military discipline slipping. Legion recruitment cost increased (+25%).",
			"Generals openly challenge palace orders. Cohort morale drops sharply (-30%).",
			"Disloyal regiments have broken their oaths! Armed military mutiny in progress!"
		],
		"remedy": "Consolidate dynastic power, secure baggage train supply lines, or purge conspirators.",
		"fester_rate": 0.09,
		"recovery_rate": 0.16
	},
	"coup": {
		"title": "Noble Conspiracy",
		"icon": "👑",
		"tier_names": ["Noble Disdain", "Tax Withholding", "Aristocratic Plot", "Palace Coup"],
		"tier_colors": [Color(0.85, 0.75, 0.25), Color(0.95, 0.55, 0.2), Color(0.95, 0.25, 0.2), Color(0.8, 0.1, 0.3)],
		"descriptions": [
			"Aristocratic clans view the throne with disdain and withhold court counsel.",
			"Nobles withhold provincial revenue. Fortification maintenance falters.",
			"Shadowy cabals plot the ruler's downfall. Sabotage risks increasing.",
			"The nobility moves to seize the throne! Treasury plunder and assassination underway!"
		],
		"remedy": "Execute Purge Rivals edict, grant noble tax concessions, or offer Treasury Dole.",
		"fester_rate": 0.075,
		"recovery_rate": 0.14
	},
	"schism": {
		"title": "Religious Schism",
		"icon": "🕊️",
		"tier_names": ["Blasphemy Whispers", "Zealot Protests", "Temple Anathema", "Holy Insurrection"],
		"tier_colors": [Color(0.85, 0.75, 0.25), Color(0.95, 0.55, 0.2), Color(0.95, 0.25, 0.2), Color(0.8, 0.1, 0.3)],
		"descriptions": [
			"Priesthood condemns secular decrees. Superstition grips the citizenry.",
			"Zealots demonstrate outside shrines. Hope generation paralyzed.",
			"High Priests declare the ruler anathema. Desertions from religious ranks.",
			"Holy warriors take to the field to cleanse the realm of apostasy!"
		],
		"remedy": "Perform Divine Sacrifices at the Temple, restore temple tithes, or enact Coronation.",
		"fester_rate": 0.08,
		"recovery_rate": 0.15
	},
	"pestilence": {
		"title": "Pestilence",
		"icon": "☣️",
		"tier_names": ["Miasma Rising", "Fever Outbreak", "Raging Contagion", "Black Plague Epidemic"],
		"tier_colors": [Color(0.85, 0.75, 0.25), Color(0.95, 0.55, 0.2), Color(0.95, 0.25, 0.2), Color(0.8, 0.1, 0.3)],
		"descriptions": [
			"Foul vapors rise from overcrowded mudbrick quarters. Minor sickness.",
			"Fever spreads through dense districts. Worker speed reduced (-15%).",
			"Hospitals overwhelmed. Troops and laborers suffer continuous health attrition.",
			"Deadly plague ravages the realm! Mass casualties and collapsing civil order!"
		],
		"remedy": "Construct Tenements to reduce density, build Granary reserves, or enact quarantine.",
		"fester_rate": 0.065,
		"recovery_rate": 0.12
	}
}

# Live Active Moodles Data:
# { moodle_id: { "severity": 1..4, "progress": 0.0..1.0, "is_festering": bool, "disaster_cooldown": float } }
var active_moodles: Dictionary = {}

var eval_timer: float = 0.0

func _process(delta: float) -> void:
	eval_timer += delta
	if eval_timer >= 0.5:
		eval_timer = 0.0
		_evaluate_world_conditions()
		
	_process_moodle_timers(delta)

func _evaluate_world_conditions() -> void:
	var eco = get_node_or_null("/root/EconomyManager")
	var pol = get_node_or_null("/root/PoliticsManager")
	var pop = get_node_or_null("/root/PopulationManager")
	var dyn = get_node_or_null("/root/DynastyManager")
	var sup = get_node_or_null("/root/SupplyManager")
	
	# 1. Famine Condition (Grain depleted or running severe negative)
	var grain_amt = eco.resources.get("Grain", 1000) if eco else 1000
	var grain_delta = eco.deltas.get("Grain", 0.0) if eco else 0.0
	var famine_active = (grain_amt <= 50 or (grain_amt <= 200 and grain_delta < 0))
	_set_moodle_festering("famine", famine_active)
	
	# 2. Popular Unrest Condition (Commoner loyalty low or discontent high)
	var comm_loyalty = pol.commoners_loyalty if pol else 60.0
	var discontent = pop.discontent if pop else 0.1
	var unrest_active = (comm_loyalty <= 35.0 or discontent >= 0.50)
	_set_moodle_festering("unrest", unrest_active)
	
	# 3. Military Mutiny Condition (Dynasty crisis / low legitimacy / no rations)
	var leg = dyn.legitimacy if dyn else 80.0
	var in_crisis = dyn.in_succession_crisis if dyn else false
	var mutiny_active = (leg <= 45.0 or (in_crisis and leg <= 55.0))
	_set_moodle_festering("mutiny", mutiny_active)
	
	# 4. Noble Coup Condition (Nobility loyalty low)
	var nob_loyalty = pol.nobility_loyalty if pol else 60.0
	var coup_active = (nob_loyalty <= 30.0)
	_set_moodle_festering("coup", coup_active)
	
	# 5. Religious Schism Condition (Priesthood loyalty low)
	var priest_loyalty = pol.priesthood_loyalty if pol else 60.0
	var schism_active = (priest_loyalty <= 30.0)
	_set_moodle_festering("schism", schism_active)
	
	# 6. Pestilence Condition (High population density with high housing count)
	var density = float(pop.total_population) / float(max(1, pop.max_housing)) if pop else 0.5
	var pestilence_active = (pop and pop.urban_housing_count >= 5 and density >= 0.82)
	_set_moodle_festering("pestilence", pestilence_active)

func _set_moodle_festering(moodle_id: String, should_fester: bool) -> void:
	if should_fester:
		if not active_moodles.has(moodle_id):
			active_moodles[moodle_id] = {
				"severity": 1,
				"progress": 0.1,
				"is_festering": true,
				"disaster_cooldown": 0.0
			}
			moodle_added.emit(moodle_id, 1)
			_post_moodle_toast(moodle_id, 1, false)
		else:
			active_moodles[moodle_id].is_festering = true
	else:
		if active_moodles.has(moodle_id):
			active_moodles[moodle_id].is_festering = false

func _process_moodle_timers(delta: float) -> void:
	var to_remove: Array[String] = []
	
	for m_id in active_moodles.keys():
		var data = active_moodles[m_id]
		var def = MOODLE_DEFS[m_id]
		
		if data.disaster_cooldown > 0.0:
			data.disaster_cooldown -= delta
			
		if data.is_festering:
			# Festering: Progress increases
			var rate = def.fester_rate
			data.progress += delta * rate
			
			if data.progress >= 1.0:
				data.progress = 0.0
				if data.severity < 4:
					data.severity += 1
					moodle_escalated.emit(m_id, data.severity)
					_post_moodle_toast(m_id, data.severity, true)
				else:
					# At Max Tier 4 -> Trigger Acute Disaster if cooldown ready
					if data.disaster_cooldown <= 0.0:
						_trigger_acute_disaster(m_id)
						data.disaster_cooldown = 40.0 # 40s between disaster strikes while at tier 4
			
			moodle_updated.emit(m_id, data.severity, data.progress)
		else:
			# Recovering: Progress decreases
			var rate = def.recovery_rate
			data.progress -= delta * rate
			
			if data.progress <= 0.0:
				if data.severity > 1:
					data.severity -= 1
					data.progress = 0.95
					moodle_escalated.emit(m_id, data.severity)
				else:
					# Fully Cleared!
					to_remove.append(m_id)
			else:
				moodle_updated.emit(m_id, data.severity, data.progress)
				
	for m_id in to_remove:
		active_moodles.erase(m_id)
		moodle_removed.emit(m_id)
		var eb = get_node_or_null("/root/EventBus")
		if eb:
			var def = MOODLE_DEFS[m_id]
			eb.post_notification("AFFLICTION RESOLVED", "%s %s has subsided." % [def.icon, def.title], Color(0.4, 0.95, 0.5))

func _post_moodle_toast(moodle_id: String, tier: int, is_escalation: bool) -> void:
	var eb = get_node_or_null("/root/EventBus")
	if not eb: return
	var def = MOODLE_DEFS[moodle_id]
	var t_name = def.tier_names[tier - 1]
	var color = def.tier_colors[tier - 1]
	var prefix = "AFFLICTION ESCALATED: " if is_escalation else "NEW AFFLICTION: "
	eb.post_notification(prefix + def.title.to_upper(), "%s (Tier %d) — %s" % [t_name, tier, def.descriptions[tier - 1]], color)

# --- ACUTE DISASTER CONSEQUENCES ---

func _trigger_acute_disaster(moodle_id: String) -> void:
	var def = MOODLE_DEFS[moodle_id]
	var eb = get_node_or_null("/root/EventBus")
	var am = get_node_or_null("/root/AudioManager")
	if am: am.play_sfx("attack")
	
	match moodle_id:
		"famine":
			if eb: eb.post_notification("🔥 GRANARY BREAD RIOTS!", "Starving mobs storm granaries and set fire to tenements!", Color(1.0, 0.15, 0.15))
			disaster_triggered.emit(moodle_id, "GranaryBreadRiots")
			_spawn_rebel_mob("raider", 3)
			_plunder_resource("Grain", 300)
			
		"unrest":
			if eb: eb.post_notification("🔥 PEASANT STRIKE & CITY RIOT!", "General strike paralyses collection! Armed rioters clash with the guard!", Color(1.0, 0.15, 0.15))
			disaster_triggered.emit(moodle_id, "PeasantStrike")
			_spawn_rebel_mob("spearman", 4)
			_halt_production_temporarily(12.0)
			
		"mutiny":
			if eb: eb.post_notification("🔥 MILITARY REGIMENTAL MUTINY!", "Disloyal officers turn their cohorts against the citadel!", Color(1.0, 0.1, 0.1))
			disaster_triggered.emit(moodle_id, "RegimentalMutiny")
			_spawn_rebel_mob("spearman", 4)
			_spawn_rebel_mob("chariot", 1)
			
		"coup":
			if eb: eb.post_notification("🔥 ARISTOCRATIC PALACE COUP!", "Noble retainers sack the treasury and attempt an assassination!", Color(1.0, 0.2, 0.2))
			disaster_triggered.emit(moodle_id, "PalaceCoup")
			_plunder_resource("Gold", 400)
			_spawn_rebel_mob("raider", 3)
			
		"schism":
			if eb: eb.post_notification("🔥 ZEALOT HOLY INSURRECTION!", "Temple fanatics desecrate civic monuments and attack barracks!", Color(1.0, 0.3, 0.1))
			disaster_triggered.emit(moodle_id, "HolyInsurrection")
			_spawn_rebel_mob("raider", 4)
			
		"pestilence":
			if eb: eb.post_notification("☣️ BLACK PLAGUE EPIDEMIC!", "The epidemic reaches catastrophic levels! High mortality strikes the realm!", Color(0.7, 0.2, 0.8))
			disaster_triggered.emit(moodle_id, "PlagueEpidemic")
			var pop = get_node_or_null("/root/PopulationManager")
			if pop: pop.modify_population(-25)

func _spawn_rebel_mob(unit_type: String, count: int) -> void:
	var world = get_tree().root.get_node_or_null("Main/World")
	if not world: return
	var unit_scene = load("res://scenes/units/Unit.tscn")
	if not unit_scene: return
	
	for i in range(count):
		var u = unit_scene.instantiate()
		u.unit_type = unit_type
		u.team_id = 1 # Hostile
		u.position = Vector3(randf_range(-15, 15), 0.0, randf_range(25, 45))
		world.add_child(u)

func _plunder_resource(res_name: String, amount: int) -> void:
	var eco = get_node_or_null("/root/EconomyManager")
	if eco:
		eco.resources[res_name] = max(0, eco.resources.get(res_name, 0) - amount)
		var eb = get_node_or_null("/root/EventBus")
		if eb: eb.economy_updated.emit(eco.resources, eco.deltas)

func _halt_production_temporarily(duration: float) -> void:
	var eco = get_node_or_null("/root/EconomyManager")
	if not eco: return
	var original_gold_delta = eco.deltas.get("Gold", 80.0)
	eco.deltas["Gold"] = 0.0
	get_tree().create_timer(duration).timeout.connect(func():
		if eco:
			eco.deltas["Gold"] = original_gold_delta
			var eb = get_node_or_null("/root/EventBus")
			if eb: eb.economy_updated.emit(eco.resources, eco.deltas)
	)

# --- SYSTEMIC PASSIVE DEBUFF ACCESSORS ---

func get_economy_multiplier() -> float:
	var mult = 1.0
	if active_moodles.has("unrest"):
		mult -= active_moodles["unrest"].severity * 0.10 # -10% to -40% Gold income
	if active_moodles.has("famine"):
		mult -= active_moodles["famine"].severity * 0.08 # -8% to -32% output
	return max(0.2, mult)

func get_recruit_cost_multiplier() -> float:
	var mult = 1.0
	if active_moodles.has("mutiny"):
		mult += active_moodles["mutiny"].severity * 0.15 # +15% to +60% recruit cost
	return mult

func get_unit_morale_modifier() -> float:
	var mod = 0.0
	if active_moodles.has("mutiny"):
		mod -= active_moodles["mutiny"].severity * 10.0 # -10 to -40 Morale
	if active_moodles.has("famine"):
		mod -= active_moodles["famine"].severity * 5.0
	return mod

func is_moodle_active(moodle_id: String) -> bool:
	return active_moodles.has(moodle_id)

func get_moodle_severity(moodle_id: String) -> int:
	if active_moodles.has(moodle_id):
		return active_moodles[moodle_id].severity
	return 0
