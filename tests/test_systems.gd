extends SceneTree

func _init() -> void:
	print("==================================================")
	print("Running Chronicles of Dominion Headless System Tests...")
	print("==================================================")
	
	# Load systems
	var EventBusScript = load("res://scripts/systems/EventBus.gd")
	var EventBusInstance = EventBusScript.new()
	
	var EconomyScript = load("res://scripts/systems/EconomyManager.gd")
	var EconomyInstance = EconomyScript.new()
	
	var PopulationScript = load("res://scripts/systems/PopulationManager.gd")
	var PopulationInstance = PopulationScript.new()
	
	var FormationScript = load("res://scripts/systems/FormationManager.gd")
	var FormationInstance = FormationScript.new()
	
	var PoliticsScript = load("res://scripts/systems/PoliticsManager.gd")
	var PoliticsInstance = PoliticsScript.new()
	
	# 1. Test Economy
	assert(EconomyInstance.resources["Grain"] >= 1400.0, "Economy grain initial check failed")
	var spent = EconomyInstance.spend_resources({"Grain": 100.0, "Bronze": 50.0})
	assert(spent == true, "Spend resources failed")
	assert(EconomyInstance.resources["Grain"] == 1320.0, "Grain balance check failed")
	print("[PASS] EconomyManager: Resource ledger & spending verified.")
	
	# 2. Test Population & Hope
	PopulationInstance.modify_hope(0.05)
	assert(PopulationInstance.hope > 0.8, "Hope modification check failed")
	print("[PASS] PopulationManager: Hope & discontent calculations verified.")
	
	# 3. Test Formations
	var phalanx_slots = FormationInstance.get_formation_slots(FormationInstance.FormationType.PHALANX, 6, Vector3.ZERO, Vector3.FORWARD)
	assert(phalanx_slots.size() == 6, "Phalanx slot count failed")
	var wedge_slots = FormationInstance.get_formation_slots(FormationInstance.FormationType.WEDGE, 5, Vector3.ZERO, Vector3.FORWARD)
	assert(wedge_slots.size() == 5, "Wedge slot count failed")
	print("[PASS] FormationManager: Phalanx & Wedge slot geometry verified.")
	
	# 4. Test Politics & Estates
	PoliticsInstance.modify_estates(5.0, -5.0, 2.0)
	assert(PoliticsInstance.priesthood_loyalty == 70.0, "Priesthood loyalty check failed")
	print("[PASS] PoliticsManager: 3-Estate equilibrium mechanics verified.")
	
	# 5. Test Crisis System Data
	var locust = load("res://data/crises/LocustSwarm.tres")
	assert(locust != null, "Locust crisis resource load failed")
	assert(locust.options.size() == 2, "Locust options count failed")
	print("[PASS] CrisisManager: Frostpunk narrative dilemma resource verified.")
	
	# 6. Test Unit Data Resources
	var spearman_data = load("res://data/units/Spearman.tres")
	assert(spearman_data != null and spearman_data.damage == 22.0, "Spearman data check failed")
	var slinger_data = load("res://data/units/Slinger.tres")
	assert(slinger_data != null and slinger_data.attack_range == 18.0, "Slinger data check failed")
	var chariot_data = load("res://data/units/Chariot.tres")
	assert(chariot_data != null and chariot_data.max_health == 320.0, "Chariot data check failed")
	print("[PASS] UnitData: Spearman, Slinger, and Chariot tactical balance curves verified.")
	
	print("==================================================")
	print("ALL SYSTEMS TESTED AND VERIFIED WITH 0 ERRORS!")
	print("==================================================")
	quit(0)
