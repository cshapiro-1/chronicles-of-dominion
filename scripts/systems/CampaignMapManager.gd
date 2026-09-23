extends Node

signal province_updated(province_id: String)
signal caravan_spawned(caravan_data: Dictionary)
signal view_mode_changed(mode: String) # "TACTICAL_3D" or "STRATEGIC_OVERWORLD"

var active_view_mode: String = "TACTICAL_3D"

var provinces = {
	"ur_kish": {
		"name": "Citadel of Ur-Kish",
		"owner": "player",
		"population": 8500,
		"tax_rate": "normal", # "low", "normal", "high", "harsh"
		"public_order": 92.0,
		"grain_yield": 45.0,
		"gold_yield": 80.0,
		"garrison": 6,
		"roads_built": true,
		"canals_built": true,
		"pos_2d": Vector2(400, 350)
	},
	"babylon": {
		"name": "Babylon (Kadingirra)",
		"owner": "player",
		"population": 12000,
		"tax_rate": "normal",
		"public_order": 85.0,
		"grain_yield": 65.0,
		"gold_yield": 110.0,
		"garrison": 8,
		"roads_built": true,
		"canals_built": false,
		"pos_2d": Vector2(620, 280)
	},
	"nineveh": {
		"name": "Nineveh Citadel",
		"owner": "neutral",
		"population": 7200,
		"tax_rate": "normal",
		"public_order": 78.0,
		"grain_yield": 30.0,
		"gold_yield": 60.0,
		"garrison": 5,
		"roads_built": false,
		"canals_built": false,
		"pos_2d": Vector2(300, 160)
	},
	"susa": {
		"name": "Susa Gateway",
		"owner": "neutral",
		"population": 6500,
		"tax_rate": "normal",
		"public_order": 80.0,
		"grain_yield": 35.0,
		"gold_yield": 95.0,
		"garrison": 4,
		"roads_built": false,
		"canals_built": false,
		"pos_2d": Vector2(850, 420)
	},
	"lagash": {
		"name": "Lagash Canal Basin",
		"owner": "player",
		"population": 9400,
		"tax_rate": "normal",
		"public_order": 88.0,
		"grain_yield": 70.0,
		"gold_yield": 50.0,
		"garrison": 4,
		"roads_built": false,
		"canals_built": true,
		"pos_2d": Vector2(580, 520)
	},
	"eridu": {
		"name": "Sacred Eridu",
		"owner": "enemy", # Nomad / Rival seat
		"population": 5800,
		"tax_rate": "high",
		"public_order": 55.0,
		"grain_yield": 25.0,
		"gold_yield": 40.0,
		"garrison": 7,
		"roads_built": false,
		"canals_built": false,
		"pos_2d": Vector2(740, 680)
	}
}

var active_caravans: Array[Dictionary] = []
var trade_tick_timer: float = 0.0

func _process(delta: float) -> void:
	trade_tick_timer += delta
	if trade_tick_timer >= 5.0:
		trade_tick_timer = 0.0
		_process_provincial_macro_economy()
		_spawn_routine_trade_caravan()
		
	# Move active caravans
	for c in active_caravans:
		c.progress += delta * 0.15
		if c.progress >= 1.0:
			_complete_caravan(c)
	active_caravans = active_caravans.filter(func(c): return c.progress < 1.0)

func toggle_view_mode() -> void:
	if active_view_mode == "TACTICAL_3D":
		set_view_mode("STRATEGIC_OVERWORLD")
	else:
		set_view_mode("TACTICAL_3D")

func set_view_mode(mode: String) -> void:
	active_view_mode = mode
	view_mode_changed.emit(mode)
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		var txt = "STRATEGIC OVERWORLD MAP" if mode == "STRATEGIC_OVERWORLD" else "3D TACTICAL BATTLEFIELD"
		eb.post_notification("MAP VIEW CHANGED", "Switched to %s mode." % txt, Color(0.3, 0.85, 1.0))

func set_province_tax(province_id: String, new_rate: String) -> void:
	if not provinces.has(province_id): return
	var p = provinces[province_id]
	p.tax_rate = new_rate
	
	match new_rate:
		"low":
			p.public_order = min(100.0, p.public_order + 10.0)
		"normal":
			pass
		"high":
			p.public_order = max(0.0, p.public_order - 12.0)
		"harsh":
			p.public_order = max(0.0, p.public_order - 25.0)
			
	province_updated.emit(province_id)

func build_provincial_infrastructure(province_id: String, infra_type: String) -> bool:
	if not provinces.has(province_id): return false
	var p = provinces[province_id]
	var eco = get_node_or_null("/root/EconomyManager")
	var eb = get_node_or_null("/root/EventBus")
	
	if infra_type == "roads":
		if p.roads_built: return false
		if eco and eco.resources.get("Stone", 0) < 200:
			if eb: eb.post_notification("INSUFFICIENT STONE", "Need 200 Stone for Provincial Road.", Color(1, 0.3, 0.3))
			return false
		if eco: eco.resources["Stone"] -= 200
		p.roads_built = true
		p.gold_yield += 25.0
		if eb: eb.post_notification("INFRASTRUCTURE BUILT", "%s constructed Royal Paved Highway (+25 Gold/m)." % p.name, Color(0.4, 0.95, 0.5))
		province_updated.emit(province_id)
		return true
		
	elif infra_type == "canals":
		if p.canals_built: return false
		if eco and eco.resources.get("Timber", 0) < 150:
			if eb: eb.post_notification("INSUFFICIENT TIMBER", "Need 150 Timber for Irrigation Canal.", Color(1, 0.3, 0.3))
			return false
		if eco: eco.resources["Timber"] -= 150
		p.canals_built = true
		p.grain_yield += 35.0
		if eb: eb.post_notification("INFRASTRUCTURE BUILT", "%s constructed Irrigation Canal Network (+35 Grain/m)." % p.name, Color(0.4, 0.95, 0.5))
		province_updated.emit(province_id)
		return true
		
	return false

func _process_provincial_macro_economy() -> void:
	var total_grain = 0.0
	var total_gold = 0.0
	for p_id in provinces:
		var p = provinces[p_id]
		if p.owner == "player":
			var tax_mult = 0.7 if p.tax_rate == "low" else (1.0 if p.tax_rate == "normal" else (1.4 if p.tax_rate == "high" else 1.8))
			total_grain += p.grain_yield * (p.public_order / 100.0)
			total_gold += p.gold_yield * tax_mult * (p.public_order / 100.0)
			
	var eco = get_node_or_null("/root/EconomyManager")
	if eco:
		eco.resources["Grain"] = eco.resources.get("Grain", 0) + int(total_grain * 0.1)
		eco.resources["Gold"] = eco.resources.get("Gold", 0) + int(total_gold * 0.1)
		var eb = get_node_or_null("/root/EventBus")
		if eb: eb.economy_updated.emit(eco.resources, eco.deltas)

func _spawn_routine_trade_caravan() -> void:
	var from_p = "ur_kish"
	var to_p = "babylon" if randf() < 0.5 else "lagash"
	var caravan = {
		"from": from_p,
		"to": to_p,
		"cargo_gold": 120,
		"progress": 0.0
	}
	active_caravans.append(caravan)
	caravan_spawned.emit(caravan)

func _complete_caravan(c: Dictionary) -> void:
	var eco = get_node_or_null("/root/EconomyManager")
	if eco:
		eco.resources["Gold"] = eco.resources.get("Gold", 0) + c.cargo_gold
	var eb = get_node_or_null("/root/EventBus")
	if eb:
		eb.post_notification("CARAVAN ARRIVED", "Merchant caravan from %s reached %s (+%d Gold)." % [
			provinces[c.from].name, provinces[c.to].name, c.cargo_gold
		], Color(0.95, 0.85, 0.35))
