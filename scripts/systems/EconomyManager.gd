extends Node

var resources: Dictionary = {
	"Grain": 1420.0,
	"Timber": 850.0,
	"Stone": 1200.0,
	"Bronze": 650.0,
	"Gold": 5200.0,
	"Capacity": 6500.0
}

var deltas: Dictionary = {
	"Grain": 45.0, # +45/min
	"Timber": 18.0,
	"Stone": 25.0,
	"Bronze": 12.0,
	"Gold": 80.0,
	"Capacity": 100.0
}

var tick_timer: float = 0.0
const TICK_INTERVAL: float = 1.0

func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	tick_timer += delta
	if tick_timer >= TICK_INTERVAL:
		tick_timer = 0.0
		_process_economy_tick()

func _process_economy_tick() -> void:
	for res in ["Grain", "Timber", "Stone", "Bronze", "Gold"]:
		resources[res] += (deltas[res] / 60.0)
	EventBus.economy_updated.emit(resources, deltas)

func can_afford(cost: Dictionary) -> bool:
	for res in cost:
		if resources.get(res, 0.0) < cost[res]:
			return false
	return true

func spend_resources(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	for res in cost:
		resources[res] -= cost[res]
	EventBus.economy_updated.emit(resources, deltas)
	return true

func add_resources(amount: Dictionary) -> void:
	for res in amount:
		resources[res] = resources.get(res, 0.0) + amount[res]
	EventBus.economy_updated.emit(resources, deltas)
