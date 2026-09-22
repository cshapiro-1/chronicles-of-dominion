class_name SimpleClairvoyantAI
extends Node

var eco_controller: AIEconomyController
var const_controller: AIConstructionWorksController
var offense_controller: AIOffenseController

func _ready() -> void:
	eco_controller = AIEconomyController.new(self)
	const_controller = AIConstructionWorksController.new(self)
	offense_controller = AIOffenseController.new(self)

func _process(delta: float) -> void:
	eco_controller.update(delta)
	const_controller.update(delta)
	offense_controller.update(delta)
