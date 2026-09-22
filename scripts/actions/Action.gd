extends RefCounted

var unit: Node = null
var is_finished: bool = false

func _init(p_unit: Node = null) -> void:
	unit = p_unit

func start() -> void:
	pass

func process(_delta: float) -> void:
	pass

func stop() -> void:
	is_finished = true
