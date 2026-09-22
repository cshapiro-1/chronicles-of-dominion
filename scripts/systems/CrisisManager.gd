extends Node

var active_crisis: Resource = null
var triggered_crises_cooldown: Dictionary = {}
const COOLDOWN_TIME: float = 60.0

var loaded_crises: Dictionary = {}

func _ready() -> void:
	_load_crisis_resources()

func _load_crisis_resources() -> void:
	var list = [
		"PestilenceMudbrick",
		"TheocraticDominance",
		"GranaryBreadRiots",
		"NobleHoarding",
		"BloodEclipse",
		"LocustSwarm"
	]
	for c_name in list:
		var p = "res://data/crises/%s.tres" % c_name
		if ResourceLoader.exists(p):
			var res = load(p)
			if res:
				loaded_crises[c_name] = res

func _process(delta: float) -> void:
	# Tick cooldowns for triggered crises
	for k in triggered_crises_cooldown.keys():
		triggered_crises_cooldown[k] -= delta
		if triggered_crises_cooldown[k] <= 0:
			triggered_crises_cooldown.erase(k)

# --- SYSTEMIC PLAYER-ACTION TRIGGERS (CAUSE & EFFECT) ---

## 1. Urban Housing Overcrowding -> Disease Spread
func on_urban_housing_built(total_housing: int, pop_density: float = 1.0) -> void:
	if total_housing >= 6 or pop_density >= 0.85:
		_attempt_trigger_crisis("PestilenceMudbrick")

## 2. Tithes & Church Dominance -> Theocracy & Economic Drain
func on_tithes_raised(priesthood_loyalty: float) -> void:
	if priesthood_loyalty >= 75.0:
		_attempt_trigger_crisis("TheocraticDominance")

## 3. Oppression & Discontent -> Granary Bread Riots
func on_commoners_discontent_spike(commoners_loyalty: float, discontent: float) -> void:
	if commoners_loyalty <= 28.0 or discontent >= 0.65:
		_attempt_trigger_crisis("GranaryBreadRiots")

## 4. Grain Depletion -> Noble Hoarding / Famine
func on_grain_low(grain_amount: float) -> void:
	if grain_amount < 150.0:
		_attempt_trigger_crisis("NobleHoarding")

func _attempt_trigger_crisis(crisis_key: String) -> void:
	if active_crisis != null:
		return # Do not overlap modal crises
	if triggered_crises_cooldown.has(crisis_key):
		return # On cooldown
		
	if loaded_crises.has(crisis_key):
		var crisis_res = loaded_crises[crisis_key]
		triggered_crises_cooldown[crisis_key] = COOLDOWN_TIME
		trigger_crisis(crisis_res)

func trigger_crisis(crisis_data: Resource) -> void:
	active_crisis = crisis_data
	GameManager.set_game_state(GameManager.GameState.CRISIS_PAUSED)
	EventBus.crisis_triggered.emit(crisis_data)

func resolve_crisis(option_index: int) -> void:
	if not active_crisis:
		return
	
	active_crisis.apply_choice(option_index)
	EventBus.crisis_resolved.emit(active_crisis, option_index)
	active_crisis = null
	GameManager.set_game_state(GameManager.GameState.PLAYING)
