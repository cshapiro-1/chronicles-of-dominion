class_name SimpleClairvoyantAI
extends Node

var eco_controller: AIEconomyController = null
var const_controller: AIConstructionWorksController = null
var offense_controller: AIOffenseController = null

func _init() -> void:
	eco_controller = AIEconomyController.new(self)
	const_controller = AIConstructionWorksController.new(self)
	offense_controller = AIOffenseController.new(self)

func _ready() -> void:
	if not eco_controller: eco_controller = AIEconomyController.new(self)
	if not const_controller: const_controller = AIConstructionWorksController.new(self)
	if not offense_controller: offense_controller = AIOffenseController.new(self)

func _process(delta: float) -> void:
	if eco_controller: eco_controller.update(delta)
	if const_controller: const_controller.update(delta)
	if offense_controller: offense_controller.update(delta)
