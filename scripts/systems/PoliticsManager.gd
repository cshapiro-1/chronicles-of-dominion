extends Node

var priesthood_loyalty: float = 65.0
var nobility_loyalty: float = 60.0
var commoners_loyalty: float = 58.0
var tithe_rate: float = 0.10

func modify_estates(p: float, n: float, c: float) -> void:
	priesthood_loyalty = clamp(priesthood_loyalty + p, 0.0, 100.0)
	nobility_loyalty = clamp(nobility_loyalty + n, 0.0, 100.0)
	commoners_loyalty = clamp(commoners_loyalty + c, 0.0, 100.0)
	EventBus.estates_updated.emit(priesthood_loyalty, nobility_loyalty, commoners_loyalty)
	_check_political_crises()

func adjust_loyalty(estate: String, amount: float) -> void:
	match estate.to_lower():
		"priesthood", "altar":
			priesthood_loyalty = clamp(priesthood_loyalty + amount, 0.0, 100.0)
		"nobility", "throne":
			nobility_loyalty = clamp(nobility_loyalty + amount, 0.0, 100.0)
		"commoners", "masses":
			commoners_loyalty = clamp(commoners_loyalty + amount, 0.0, 100.0)
	EventBus.estates_updated.emit(priesthood_loyalty, nobility_loyalty, commoners_loyalty)
	_check_political_crises()

func raise_tithes() -> void:
	tithe_rate += 0.05
	priesthood_loyalty = clamp(priesthood_loyalty + 12.0, 0.0, 100.0)
	commoners_loyalty = clamp(commoners_loyalty - 8.0, 0.0, 100.0)
	
	# The economy suffers as the church concentrates bullion
	EconomyManager.deltas["Gold"] = max(5.0, EconomyManager.deltas.get("Gold", 80.0) - 15.0)
	EventBus.notification_posted.emit("TITHES RAISED", "Temple tithes increased. Church influence expands, economy loses bullion.", Color(0.95, 0.85, 0.3))
	EventBus.estates_updated.emit(priesthood_loyalty, nobility_loyalty, commoners_loyalty)
	EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)
	
	if CrisisManager:
		CrisisManager.on_tithes_raised(priesthood_loyalty)

func lower_tithes() -> void:
	tithe_rate = max(0.0, tithe_rate - 0.05)
	priesthood_loyalty = clamp(priesthood_loyalty - 12.0, 0.0, 100.0)
	commoners_loyalty = clamp(commoners_loyalty + 8.0, 0.0, 100.0)
	EconomyManager.deltas["Gold"] = EconomyManager.deltas.get("Gold", 80.0) + 15.0
	EventBus.notification_posted.emit("TITHES REDUCED", "Secular trade unburdened. +15 Gold/m income.", Color(0.4, 0.9, 0.5))
	EventBus.estates_updated.emit(priesthood_loyalty, nobility_loyalty, commoners_loyalty)
	EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)

func _check_political_crises() -> void:
	if not CrisisManager: return
	if priesthood_loyalty >= 75.0:
		CrisisManager.on_tithes_raised(priesthood_loyalty)
	if commoners_loyalty <= 28.0:
		CrisisManager.on_commoners_discontent_spike(commoners_loyalty, PopulationManager.discontent)
