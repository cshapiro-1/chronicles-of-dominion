class_name TraitProductionQueue
extends Node

signal queue_updated()
signal item_completed(unit_type: String)

@export var max_queue_size: int = 5
var queue: Array = [] # Array of { "type": String, "duration": float, "progress": float, "cost": Dictionary }

func enqueue(unit_type: String, duration: float, cost: Dictionary) -> bool:
	if queue.size() >= max_queue_size:
		return false
	queue.append({
		"type": unit_type,
		"duration": duration,
		"progress": 0.0,
		"cost": cost
	})
	queue_updated.emit()
	return true

func cancel_item(index: int) -> Dictionary:
	if index < 0 or index >= queue.size():
		return {}
	var item = queue[index]
	queue.remove_at(index)
	queue_updated.emit()
	return item.get("cost", {})

func process_queue(delta: float) -> void:
	if queue.is_empty():
		return
	var current = queue[0]
	current["progress"] += delta
	if current["progress"] >= current["duration"]:
		var completed_type = current["type"]
		queue.remove_at(0)
		queue_updated.emit()
		item_completed.emit(completed_type)
