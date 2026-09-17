extends "res://scenes/buildings/Building.gd"

@export var grain_yield_per_sec: float = 1.2

func _ready() -> void:
	super._ready()
	EconomyManager.deltas["Grain"] += (grain_yield_per_sec * 60.0)
	EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)

func _exit_tree() -> void:
	EconomyManager.deltas["Grain"] -= (grain_yield_per_sec * 60.0)
	EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)
