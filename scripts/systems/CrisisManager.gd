extends Node

var crisis_pool: Array[Resource] = []
var active_crisis: Resource = null
var crisis_timer: float = 0.0
const CRISIS_INTERVAL: float = 75.0

func _ready() -> void:
	_load_crises()

func _load_crises() -> void:
	var c1 = load("res://data/crises/LocustSwarm.tres")
	if c1: crisis_pool.append(c1)
	var c2 = load("res://data/crises/NobleHoarding.tres")
	if c2: crisis_pool.append(c2)
	var c3 = load("res://data/crises/BloodEclipse.tres")
	if c3: crisis_pool.append(c3)

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	crisis_timer += delta
	if crisis_timer >= CRISIS_INTERVAL:
		crisis_timer = 0.0
		trigger_random_crisis()

func trigger_random_crisis() -> void:
	if crisis_pool.is_empty():
		return
	var c = crisis_pool.pick_random()
	trigger_crisis(c)

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
