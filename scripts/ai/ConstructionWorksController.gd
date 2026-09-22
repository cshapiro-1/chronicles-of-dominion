class_name AIConstructionWorksController
extends RefCounted

var ai_player: Node = null
var build_cooldown: float = 20.0
var time_since_build: float = 0.0

func _init(p_ai: Node) -> void:
	ai_player = p_ai

func update(delta: float) -> void:
	time_since_build += delta
	if time_since_build >= build_cooldown:
		time_since_build = 0.0
		# Automatically place watchtower or training camp if resources permit
		_try_expand_fortifications()

func _try_expand_fortifications() -> void:
	var citadel = ai_player.get_tree().get_first_node_in_group("EnemyCitadel")
	if citadel:
		var offset = Vector3(randf_range(-15, 15), 0, randf_range(-15, 15))
		MatchSignals.structure_placed.emit("watchtower", citadel.global_position + offset)
