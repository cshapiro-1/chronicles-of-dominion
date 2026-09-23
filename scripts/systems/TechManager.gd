extends Node

enum Epoch {
	BRONZE = 1,
	IRON = 2,
	FEUDAL = 3,
	STEAM = 4
}

var current_epoch: Epoch = Epoch.BRONZE
var researched_techs: Array[String] = []
var active_research: String = ""
var research_progress: float = 0.0
var research_time_required: float = 10.0

const TECH_DATABASE = {
	# EPOCH I: BRONZE AGE
	"composite_bows": {
		"name": "Composite Bows",
		"epoch": Epoch.BRONZE,
		"gold_cost": 150,
		"timber_cost": 80,
		"time": 8.0,
		"description": "+25% Archer Range and +15% Ranged Damage",
		"requires": []
	},
	"phalanx_drills": {
		"name": "Phalanx Drills",
		"epoch": Epoch.BRONZE,
		"gold_cost": 120,
		"bronze_cost": 60,
		"time": 6.0,
		"description": "+30% Spearman Armor and +20% Bracing vs Cavalry",
		"requires": []
	},
	"mudbrick_kilns": {
		"name": "Mudbrick Kilns",
		"epoch": Epoch.BRONZE,
		"gold_cost": 100,
		"stone_cost": 80,
		"time": 6.0,
		"description": "+40% Structure Construction Speed",
		"requires": []
	},
	
	# EPOCH II: IRON AGE
	"epoch_iron": {
		"name": "Advance to Iron Age",
		"epoch": Epoch.BRONZE,
		"gold_cost": 500,
		"bronze_cost": 250,
		"time": 15.0,
		"description": "Unlocks Iron Age Technologies, Advanced Chariots, and Bastion Forts",
		"requires": ["phalanx_drills", "mudbrick_kilns"]
	},
	"iron_metallurgy": {
		"name": "Iron Metallurgy",
		"epoch": Epoch.IRON,
		"gold_cost": 300,
		"stone_cost": 150,
		"time": 10.0,
		"description": "+35% Melee Attack Damage across all regiments",
		"requires": ["epoch_iron"]
	},
	"granary_buffering": {
		"name": "Granary Buffering",
		"epoch": Epoch.IRON,
		"gold_cost": 250,
		"timber_cost": 120,
		"time": 8.0,
		"description": "+50% Granary Storage and +20m Supply Line Radius",
		"requires": ["epoch_iron"]
	},
	"spoked_chariots": {
		"name": "Spoked Wheel Chariots",
		"epoch": Epoch.IRON,
		"gold_cost": 400,
		"timber_cost": 180,
		"time": 12.0,
		"description": "+30% War Chariot Speed and +40% Trample Damage",
		"requires": ["epoch_iron"]
	},
	
	# EPOCH III: FEUDAL AGE
	"epoch_feudal": {
		"name": "Advance to Feudal Age",
		"epoch": Epoch.IRON,
		"gold_cost": 1200,
		"stone_cost": 600,
		"time": 25.0,
		"description": "Unlocks Feudal Age Technologies, Heavy Knights, and Stone Fortresses",
		"requires": ["iron_metallurgy", "granary_buffering"]
	},
	"irrigation_canals": {
		"name": "Irrigation Canals",
		"epoch": Epoch.FEUDAL,
		"gold_cost": 500,
		"stone_cost": 300,
		"time": 14.0,
		"description": "+50% Farm Grain Yield and +15% Population Growth",
		"requires": ["epoch_feudal"]
	},
	"plate_armor": {
		"name": "Tempered Plate Armor",
		"epoch": Epoch.FEUDAL,
		"gold_cost": 600,
		"bronze_cost": 300,
		"time": 16.0,
		"description": "+50% Infantry & Cavalry Health",
		"requires": ["epoch_feudal"]
	},
	
	# EPOCH IV: STEAM AGE
	"epoch_steam": {
		"name": "Advance to Steam Age",
		"epoch": Epoch.FEUDAL,
		"gold_cost": 2500,
		"stone_cost": 1200,
		"time": 35.0,
		"description": "Unlocks Steam Age: Industrial Factories, Steam Pumps, and Black Powder Artillery",
		"requires": ["irrigation_canals", "plate_armor"]
	},
	"black_powder_artillery": {
		"name": "Black Powder Artillery",
		"epoch": Epoch.STEAM,
		"gold_cost": 1000,
		"bronze_cost": 500,
		"time": 20.0,
		"description": "Unlocks Bombard Cannons with catastrophic siege range & splash damage",
		"requires": ["epoch_steam"]
	},
	"steam_pumps": {
		"name": "Steam Canal Pumps",
		"epoch": Epoch.STEAM,
		"gold_cost": 800,
		"stone_cost": 400,
		"time": 18.0,
		"description": "+80% Agricultural and Marketplace Output across all provinces",
		"requires": ["epoch_steam"]
	}
}

func _process(delta: float) -> void:
	if active_research != "":
		research_progress += delta
		if research_progress >= research_time_required:
			_complete_research(active_research)

func can_research(tech_id: String) -> bool:
	if not TECH_DATABASE.has(tech_id):
		return false
	if is_tech_researched(tech_id):
		return false
	if active_research != "":
		return false
		
	var data = TECH_DATABASE[tech_id]
	for req in data.requires:
		if not is_tech_researched(req):
			return false
			
	var gold = data.get("gold_cost", 0)
	var timber = data.get("timber_cost", 0)
	var stone = data.get("stone_cost", 0)
	var bronze = data.get("bronze_cost", 0)
	
	if EconomyManager.resources.get("Gold", 0) < gold: return false
	if EconomyManager.resources.get("Timber", 0) < timber: return false
	if EconomyManager.resources.get("Stone", 0) < stone: return false
	if EconomyManager.resources.get("Bronze", 0) < bronze: return false
	return true

func start_research(tech_id: String) -> bool:
	if not can_research(tech_id):
		EventBus.post_notification("CANNOT RESEARCH", "Prerequisites or resources missing.", Color(1.0, 0.3, 0.3))
		return false
		
	var data = TECH_DATABASE[tech_id]
	var gold = data.get("gold_cost", 0)
	var timber = data.get("timber_cost", 0)
	var stone = data.get("stone_cost", 0)
	var bronze = data.get("bronze_cost", 0)
	
	EconomyManager.resources["Gold"] = EconomyManager.resources.get("Gold", 0) - gold
	EconomyManager.resources["Timber"] = EconomyManager.resources.get("Timber", 0) - timber
	EconomyManager.resources["Stone"] = EconomyManager.resources.get("Stone", 0) - stone
	EconomyManager.resources["Bronze"] = EconomyManager.resources.get("Bronze", 0) - bronze
	EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)
	
	active_research = tech_id
	research_progress = 0.0
	research_time_required = data.get("time", 10.0)
	
	EventBus.post_notification(
		"RESEARCH INITIATED",
		"Scholars researching %s (%ds)." % [data.name, int(research_time_required)],
		Color(0.3, 0.85, 1.0)
	)
	return true

func _complete_research(tech_id: String) -> void:
	researched_techs.append(tech_id)
	active_research = ""
	research_progress = 0.0
	
	var data = TECH_DATABASE[tech_id]
	if tech_id.begins_with("epoch_"):
		if tech_id == "epoch_iron":
			current_epoch = Epoch.IRON
		elif tech_id == "epoch_feudal":
			current_epoch = Epoch.FEUDAL
		elif tech_id == "epoch_steam":
			current_epoch = Epoch.STEAM
			
	_apply_tech_effects(tech_id)
	
	EventBus.post_notification(
		"INVENTION DISCOVERED",
		"%s completed! %s" % [data.name, data.description],
		Color(0.95, 0.85, 0.25)
	)

func _apply_tech_effects(tech_id: String) -> void:
	match tech_id:
		"composite_bows":
			for u in get_tree().get_nodes_in_group("Units"):
				if u.get("team_id") == 0 and "slinger" in str(u.get("unit_type")):
					u.attack_range *= 1.25
					u.attack_damage *= 1.15
		"phalanx_drills":
			for u in get_tree().get_nodes_in_group("Units"):
				if u.get("team_id") == 0 and "spearman" in str(u.get("unit_type")):
					u.max_hp *= 1.3
					u.current_hp = u.max_hp
					u.update_hp_display()
		"irrigation_canals":
			EconomyManager.deltas["Grain"] = EconomyManager.deltas.get("Grain", 0.0) * 1.5
			EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)
		"steam_pumps":
			for k in EconomyManager.deltas:
				EconomyManager.deltas[k] *= 1.8
			EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)

func is_tech_researched(tech_id: String) -> bool:
	return tech_id in researched_techs

func get_epoch_name() -> String:
	match current_epoch:
		Epoch.BRONZE: return "BRONZE AGE"
		Epoch.IRON: return "IRON AGE"
		Epoch.FEUDAL: return "FEUDAL AGE"
		Epoch.STEAM: return "STEAM AGE"
		_: return "BRONZE AGE"
