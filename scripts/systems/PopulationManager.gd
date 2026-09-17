extends Node

var total_population: int = 139
var max_housing: int = 250
var hope: float = 0.78
var discontent: float = 0.14
var conscription_pool: int = 45

func modify_hope(amount: float) -> void:
	hope = clamp(hope + amount, 0.0, 1.0)
	EventBus.population_updated.emit(total_population, hope, discontent)

func modify_discontent(amount: float) -> void:
	discontent = clamp(discontent + amount, 0.0, 1.0)
	EventBus.population_updated.emit(total_population, hope, discontent)

func modify_population(delta: int) -> void:
	total_population = max(0, total_population + delta)
	EventBus.population_updated.emit(total_population, hope, discontent)
