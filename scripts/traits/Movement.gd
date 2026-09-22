class_name TraitMovement
extends Node

@export var max_speed: float = 6.0
@export var acceleration: float = 14.0
@export var rotation_speed: float = 8.0
@export var stop_distance: float = 0.8

var current_velocity: Vector3 = Vector3.ZERO
var target_destination: Vector3 = Vector3.ZERO
var has_destination: bool = false
var unit_node: CharacterBody3D = null

func _ready() -> void:
	unit_node = get_parent() as CharacterBody3D

func move_to(destination: Vector3) -> void:
	target_destination = destination
	has_destination = true

func stop() -> void:
	has_destination = false
	current_velocity = Vector3.ZERO

func update_movement(delta: float) -> void:
	if not unit_node or not has_destination:
		return
		
	var flat_pos = Vector3(unit_node.global_position.x, 0, unit_node.global_position.z)
	var flat_target = Vector3(target_destination.x, 0, target_destination.z)
	var diff = flat_target - flat_pos
	var dist = diff.length()
	
	if dist <= stop_distance:
		has_destination = false
		current_velocity = Vector3.ZERO
		return
		
	var dir = diff.normalized()
	current_velocity = current_velocity.move_toward(dir * max_speed, acceleration * delta)
	unit_node.velocity = current_velocity
	unit_node.move_and_slide()
	
	# Smooth rotation toward movement heading
	if dir.length_squared() > 0.01:
		var target_yaw = atan2(dir.x, dir.z)
		unit_node.rotation.y = lerp_angle(unit_node.rotation.y, target_yaw, rotation_speed * delta)
