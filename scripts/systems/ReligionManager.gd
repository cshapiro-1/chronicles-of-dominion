extends Node

var divine_favor: float = 60.0
var active_blessings: Dictionary = {}

func _process(delta: float) -> void:
	for b_name in active_blessings.keys():
		active_blessings[b_name] -= delta
		if active_blessings[b_name] <= 0:
			active_blessings.erase(b_name)
			_expire_blessing(b_name)

func perform_sacrifice(sacrifice_type: String) -> bool:
	match sacrifice_type:
		"grain":
			if EconomyManager.resources.get("Grain", 0) < 300:
				EventBus.post_notification("INSUFFICIENT GRAIN", "Need 300 Grain for Sacred Offering.", Color(1, 0.3, 0.3))
				return false
			EconomyManager.resources["Grain"] -= 300
			divine_favor = min(100.0, divine_favor + 15.0)
			PoliticsManager.adjust_loyalty("priesthood", 10)
			active_blessings["bountiful_harvest"] = 45.0
			EconomyManager.deltas["Grain"] = EconomyManager.deltas.get("Grain", 0.0) + 20.0
			EventBus.post_notification("SACRED GRAIN OFFERING", "High Priesthood appeased. +20 Grain/s for 45s.", Color(0.4, 0.9, 0.5))
			return true
			
		"oxen":
			if EconomyManager.resources.get("Gold", 0) < 200:
				EventBus.post_notification("INSUFFICIENT GOLD", "Need 200 Gold to purchase Sacred Oxen.", Color(1, 0.3, 0.3))
				return false
			EconomyManager.resources["Gold"] -= 200
			divine_favor = min(100.0, divine_favor + 25.0)
			PoliticsManager.adjust_loyalty("priesthood", 15)
			active_blessings["wrath_of_shamash"] = 60.0
			for u in get_tree().get_nodes_in_group("Units"):
				if u.get("team_id") == 0:
					u.attack_damage *= 1.25
			EventBus.post_notification("WRATH OF SHAMASH", "Solar blessing invoked: +25% Army Attack for 60s!", Color(1.0, 0.85, 0.25))
			return true
	return false

func _expire_blessing(b_name: String) -> void:
	match b_name:
		"bountiful_harvest":
			EconomyManager.deltas["Grain"] = max(0.0, EconomyManager.deltas.get("Grain", 0.0) - 20.0)
			EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)
		"wrath_of_shamash":
			for u in get_tree().get_nodes_in_group("Units"):
				if u.get("team_id") == 0:
					u.attack_damage /= 1.25
