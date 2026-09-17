extends Node

var priesthood_loyalty: float = 65.0
var nobility_loyalty: float = 60.0
var commoners_loyalty: float = 58.0

func modify_estates(p: float, n: float, c: float) -> void:
	priesthood_loyalty = clamp(priesthood_loyalty + p, 0.0, 100.0)
	nobility_loyalty = clamp(nobility_loyalty + n, 0.0, 100.0)
	commoners_loyalty = clamp(commoners_loyalty + c, 0.0, 100.0)
	EventBus.estates_updated.emit(priesthood_loyalty, nobility_loyalty, commoners_loyalty)
