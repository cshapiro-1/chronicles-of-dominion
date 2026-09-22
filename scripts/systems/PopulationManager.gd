extends Node

var total_population: int = 139
var max_housing: int = 250
var urban_housing_count: int = 4
var hope: float = 0.78
var discontent: float = 0.14
var conscription_pool: int = 45

func add_urban_housing(count: int = 1) -> void:
	urban_housing_count += count
	max_housing += count * 35
	total_population += count * 20
	EventBus.population_updated.emit(total_population, hope, discontent)
	
	if CrisisManager:
		var density = float(total_population) / float(max(1, max_housing))
		CrisisManager.on_urban_housing_built(urban_housing_count, density)

func modify_hope(amount: float) -> void:
	hope = clamp(hope + amount, 0.0, 1.0)
	EventBus.population_updated.emit(total_population, hope, discontent)

func modify_discontent(amount: float) -> void:
	discontent = clamp(discontent + amount, 0.0, 1.0)
	EventBus.population_updated.emit(total_population, hope, discontent)
	if discontent >= 0.65 and CrisisManager:
		CrisisManager.on_commoners_discontent_spike(PoliticsManager.commoners_loyalty, discontent)

func modify_population(delta: int) -> void:
	total_population = max(0, total_population + delta)
	EventBus.population_updated.emit(total_population, hope, discontent)
