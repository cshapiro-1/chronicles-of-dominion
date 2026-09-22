class_name TraitTargetability
extends Node

@export var faction: int = 0 # 0 = Player, 1 = Enemy
@export var vision_range: float = 24.0
@export var attack_range: float = 8.0
@export var attack_damage: float = 18.0
@export var attack_cooldown: float = 1.2

var last_attack_time: float = -100.0

func can_attack(target: Node) -> bool:
	if not is_instance_valid(target):
		return false
	var target_trait = target.get_node_or_null("TraitTargetability")
	if not target_trait:
		return false
	return target_trait.faction != faction

func is_in_attack_range(target: Node) -> bool:
	if not is_instance_valid(target):
		return false
	var parent_3d = get_parent() as Node3D
	var target_3d = target as Node3D
	if not parent_3d or not target_3d:
		return false
	return parent_3d.global_position.distance_to(target_3d.global_position) <= attack_range
