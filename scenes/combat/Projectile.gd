extends Node3D
class_name Projectile

@export var speed: float = 24.0
@export var damage: float = 16.0
@export var projectile_type: String = "stone" # "stone" or "arrow"

var start_pos: Vector3
var target_pos: Vector3
var target_node: Node3D = null
var total_distance: float = 1.0
var travel_time: float = 1.0
var elapsed_time: float = 0.0
var peak_height: float = 2.0
var has_hit: bool = false
var team_id: int = 0

@onready var mesh_inst: MeshInstance3D = $MeshInstance3D

func launch(from_pos: Vector3, target: Node3D, dmg: float, type: String = "stone") -> void:
	start_pos = from_pos
	target_node = target
	target_pos = target.global_position + Vector3(0, 1.0, 0)
	damage = dmg
	projectile_type = type
	
	global_position = start_pos
	total_distance = max(1.0, start_pos.distance_to(target_pos))
	travel_time = total_distance / max(5.0, speed)
	peak_height = clamp(total_distance * 0.22, 1.2, 7.5)
	
	_setup_mesh()

func launch_to_position(from_pos: Vector3, dest_pos: Vector3, dmg: float, type: String = "arrow", firing_team: int = 0) -> void:
	start_pos = from_pos
	target_node = null
	target_pos = dest_pos + Vector3(0, 0.5, 0)
	damage = dmg
	projectile_type = type
	team_id = firing_team
	
	global_position = start_pos
	total_distance = max(1.0, start_pos.distance_to(target_pos))
	travel_time = total_distance / max(5.0, speed)
	peak_height = clamp(total_distance * 0.22, 1.2, 7.5)
	
	_setup_mesh()

func _setup_mesh() -> void:
	if not mesh_inst:
		mesh_inst = MeshInstance3D.new()
		add_child(mesh_inst)
		
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	if projectile_type == "arrow":
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.04
		cyl.bottom_radius = 0.04
		cyl.height = 0.8
		mesh_inst.mesh = cyl
		mat.albedo_color = Color(0.9, 0.75, 0.4)
	else:
		# Slinger stone
		var sphere = SphereMesh.new()
		sphere.radius = 0.15
		sphere.height = 0.3
		mesh_inst.mesh = sphere
		mat.albedo_color = Color(0.85, 0.80, 0.70)
		
	mesh_inst.material_override = mat

func _process(delta: float) -> void:
	if has_hit:
		return
		
	elapsed_time += delta
	var progress = clamp(elapsed_time / max(0.01, travel_time), 0.0, 1.0)
	
	# Update target position if target is still moving/alive
	if is_instance_valid(target_node):
		target_pos = target_node.global_position + Vector3(0, 1.0, 0)
		
	# Ballistic Parabolic Arc
	var current_ground = start_pos.lerp(target_pos, progress)
	var arc_y = 4.0 * peak_height * progress * (1.0 - progress)
	
	var next_pos = Vector3(current_ground.x, current_ground.y + arc_y, current_ground.z)
	
	# Orient towards flight direction
	var vel_dir = (next_pos - global_position)
	if vel_dir.length_squared() > 0.001:
		var norm_dir = vel_dir.normalized()
		var up_vec = Vector3.UP
		if abs(norm_dir.dot(Vector3.UP)) > 0.95:
			up_vec = Vector3.FORWARD
		look_at(global_position + norm_dir, up_vec)
		
	global_position = next_pos
	
	if progress >= 1.0:
		_on_impact()

func _on_impact() -> void:
	has_hit = true
	if is_instance_valid(target_node) and target_node.has_method("take_damage"):
		target_node.take_damage(damage, start_pos, true)
	else:
		# Area splash damage for ground volleys
		var units = get_tree().get_nodes_in_group("Units")
		for u in units:
			if is_instance_valid(u) and u.get("team_id") != team_id:
				if u.global_position.distance_to(global_position) <= 3.2:
					u.take_damage(damage, start_pos, true)
		
	_spawn_impact_fx()
	queue_free()

func _spawn_impact_fx() -> void:
	var root_world = get_tree().root.get_node_or_null("Main/World")
	if not root_world: return
	
	var dust = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.35
	sphere.height = 0.7
	dust.mesh = sphere
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.85, 0.75, 0.55, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dust.material_override = mat
	dust.global_position = global_position
	root_world.add_child(dust)
	
	var tween = dust.create_tween()
	tween.tween_property(dust, "scale", Vector3(1.8, 0.5, 1.8), 0.18)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.18)
	tween.tween_callback(dust.queue_free)
