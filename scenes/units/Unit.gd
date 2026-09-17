extends CharacterBody3D

@export var unit_data: UnitData

@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var hp_bar: Label3D = $HPBar
@onready var squad_root: Node3D = $SquadRoot

var team_id: int = 0
var is_selected: bool = false
var target_destination: Vector3
var has_target: bool = false
var current_hp: int = 100
var is_moving: bool = false
var march_time: float = 0.0

var soldier_nodes: Array[Node3D] = []

func _ready() -> void:
	target_destination = global_position
	selection_ring.visible = false
	
	if unit_data:
		current_hp = int(unit_data.max_health)
	update_hp_display()
	_build_squad()

func _build_squad() -> void:
	for child in squad_root.get_children():
		child.queue_free()
	soldier_nodes.clear()
	
	var unit_type = unit_data.unit_name if unit_data else "Spearman"
	
	if "Chariot" in unit_type:
		var chariot_inst = MeshInstance3D.new()
		chariot_inst.mesh = MeshFactory.create_chariot_mesh()
		squad_root.add_child(chariot_inst)
		soldier_nodes.append(chariot_inst)
	elif "Slinger" in unit_type:
		var slinger_mesh = MeshFactory.create_slinger_mesh()
		var offsets = [
			Vector3(-1.2, 0, -0.6), Vector3(0.0, 0, -0.8), Vector3(1.2, 0, -0.6),
			Vector3(-0.9, 0, 0.8), Vector3(0.9, 0, 0.8), Vector3(0.0, 0, 1.4)
		]
		for offset in offsets:
			var s_inst = MeshInstance3D.new()
			s_inst.mesh = slinger_mesh
			s_inst.position = offset
			squad_root.add_child(s_inst)
			soldier_nodes.append(s_inst)
	else:
		# 3x3 Phalanx rank of 9 spearmen
		var spear_mesh = MeshFactory.create_spearman_mesh()
		for r in range(3):
			for c in range(3):
				var s_inst = MeshInstance3D.new()
				s_inst.mesh = spear_mesh
				s_inst.position = Vector3((c - 1) * 1.1, 0, (r - 1) * 1.1)
				squad_root.add_child(s_inst)
				soldier_nodes.append(s_inst)

func _physics_process(delta: float) -> void:
	if has_target:
		var dir = (target_destination - global_position)
		dir.y = 0.0
		var dist = dir.length()
		
		if dist > 0.8:
			is_moving = true
			var speed = unit_data.move_speed if unit_data else 5.2
			velocity = dir.normalized() * speed
			
			var target_rot_y = atan2(dir.x, dir.z)
			squad_root.rotation.y = lerp_angle(squad_root.rotation.y, target_rot_y, 10.0 * delta)
			
			march_time += delta * speed * 2.8
			_animate_marching()
			
			move_and_slide()
		else:
			is_moving = false
			velocity = Vector3.ZERO
			has_target = false
			_reset_stance()
	else:
		is_moving = false
		velocity = Vector3.ZERO
		_reset_stance()

func _animate_marching() -> void:
	for i in range(soldier_nodes.size()):
		var s = soldier_nodes[i]
		var phase = march_time + i * 0.45
		s.position.y = abs(sin(phase)) * 0.08
		s.rotation.x = sin(phase) * 0.08
		s.rotation.z = cos(phase) * 0.04

func _reset_stance() -> void:
	for s in soldier_nodes:
		s.position.y = lerp(s.position.y, 0.0, 0.15)
		s.rotation.x = lerp(s.rotation.x, 0.0, 0.15)
		s.rotation.z = lerp(s.rotation.z, 0.0, 0.15)

func set_target_destination(dest: Vector3) -> void:
	target_destination = Vector3(dest.x, global_position.y, dest.z)
	has_target = true

func select() -> void:
	is_selected = true
	selection_ring.visible = true

func deselect() -> void:
	is_selected = false
	selection_ring.visible = false

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	update_hp_display()
	if current_hp <= 0:
		queue_free()

func update_hp_display() -> void:
	var max_val = int(unit_data.max_health) if unit_data else 100
	hp_bar.text = str(current_hp) + " / " + str(max_val)
	if current_hp < max_val * 0.4:
		hp_bar.modulate = Color(1.0, 0.3, 0.3)
	else:
		hp_bar.modulate = Color(1.0, 1.0, 1.0)

