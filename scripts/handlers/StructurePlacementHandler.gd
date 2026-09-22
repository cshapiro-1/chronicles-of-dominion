extends Node3D
class_name StructurePlacementHandler

var is_placing: bool = false
var ghost_structure_type: String = ""
var ghost_mesh: Node3D = null
var ghost_costs: Dictionary = {}
var is_valid_location: bool = true
var footprint_size: Vector3 = Vector3(12, 6, 12)

const BUILDING_SCENES = {
	"barracks": preload("res://scenes/buildings/Barracks.tscn"),
	"granary": preload("res://scenes/buildings/Granary.tscn"),
	"house": preload("res://scenes/buildings/House.tscn"),
	"bazaar": preload("res://scenes/buildings/Bazaar.tscn"),
	"chariot_foundry": preload("res://scenes/buildings/ChariotFoundry.tscn")
}

const BUILDING_DATA = {
	"barracks": { "name": "Military Barracks", "gold": 150, "wood": 80, "mudbrick": 40, "size": Vector3(18, 8, 16) },
	"granary": { "name": "Royal Granary", "gold": 100, "wood": 30, "mudbrick": 120, "size": Vector3(14, 8, 14) },
	"house": { "name": "Mudbrick Tenement", "gold": 60, "wood": 20, "mudbrick": 50, "size": Vector3(10, 6, 10) },
	"bazaar": { "name": "Grand Bazaar", "gold": 200, "wood": 100, "mudbrick": 60, "size": Vector3(14, 6, 14) },
	"chariot_foundry": { "name": "War Chariot Foundry", "gold": 300, "wood": 200, "mudbrick": 80, "size": Vector3(20, 8, 18) }
}

func start_placement(structure_type: String) -> void:
	var key = structure_type.to_lower()
	if not BUILDING_DATA.has(key):
		EventBus.post_notification("UNKNOWN STRUCTURE", "Cannot build %s" % structure_type, Color(1, 0.3, 0.3))
		return
		
	is_placing = true
	ghost_structure_type = key
	var data = BUILDING_DATA[key]
	ghost_costs = {
		"Gold": data.gold,
		"Wood": data.wood,
		"Mudbrick": data.mudbrick
	}
	footprint_size = data.size
	_create_ghost()

func update_ghost_position(world_pos: Vector3) -> void:
	if not is_placing or not ghost_mesh:
		return
		
	var clean_pos = Vector3(world_pos.x, 0.0, world_pos.z)
	ghost_mesh.global_position = clean_pos
	
	# Check clearance / overlap with existing StaticBodies
	is_valid_location = _check_placement_validity(clean_pos)
	_update_ghost_material(is_valid_location)

func confirm_placement() -> bool:
	if not is_placing or not ghost_mesh:
		return false
		
	if not is_valid_location:
		EventBus.post_notification("INVALID LOCATION", "Cannot place structure here. Terrain obstructed.", Color(1.0, 0.3, 0.3))
		return false
		
	# Check resources
	for res in ghost_costs:
		var cost = ghost_costs[res]
		if EconomyManager.resources.get(res, 0) < cost:
			EventBus.post_notification("INSUFFICIENT %s" % res.to_upper(), "Need %d %s (Have %d)" % [cost, res, EconomyManager.resources.get(res, 0)], Color(1.0, 0.3, 0.3))
			return false
			
	# Deduct costs
	for res in ghost_costs:
		EconomyManager.resources[res] -= ghost_costs[res]
	EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)
	
	var spawn_pos = ghost_mesh.global_position
	var type_key = ghost_structure_type
	cancel_placement()
	
	# Instantiate building
	if BUILDING_SCENES.has(type_key):
		var b_scene = BUILDING_SCENES[type_key]
		var b_inst = b_scene.instantiate()
		b_inst.position = spawn_pos
		
		var world = get_tree().root.get_node_or_null("Main/World")
		if world:
			if world.has_method("register_placed_structure"):
				world.register_placed_structure(b_inst)
			else:
				var nav_reg = world.get_node_or_null("NavigationRegion3D")
				if nav_reg:
					nav_reg.add_child(b_inst)
				else:
					world.add_child(b_inst)
		else:
			get_parent().add_child(b_inst)
			
		b_inst.start_construction()
		MatchSignals.structure_placed.emit(type_key, spawn_pos)
		return true
		
	return false

func cancel_placement() -> void:
	is_placing = false
	ghost_structure_type = ""
	if ghost_mesh:
		ghost_mesh.queue_free()
		ghost_mesh = null

func _check_placement_validity(pos: Vector3) -> bool:
	var space = get_world_3d().direct_space_state
	if not space:
		return true
		
	# Bounds check (keep within central desert region)
	if abs(pos.x) > 150.0 or abs(pos.z) > 150.0:
		return false
		
	var shape_query = PhysicsShapeQueryParameters3D.new()
	var box = BoxShape3D.new()
	box.size = footprint_size * 0.95
	shape_query.shape = box
	shape_query.transform = Transform3D(Basis(), pos + Vector3(0, footprint_size.y * 0.5, 0))
	shape_query.collision_mask = 1 # Static geometry
	
	var results = space.intersect_shape(shape_query, 8)
	for r in results:
		var collider = r.get("collider")
		# Exclude ground plane
		if collider and not (collider.name == "Ground" or collider.name.begins_with("Ground")):
			return false
	return true

func _create_ghost() -> void:
	if ghost_mesh:
		ghost_mesh.queue_free()
		
	ghost_mesh = Node3D.new()
	ghost_mesh.name = "PlacementGhost"
	
	var mi = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = footprint_size
	mi.mesh = box
	mi.position = Vector3(0, footprint_size.y * 0.5, 0)
	ghost_mesh.add_child(mi)
	
	_update_ghost_material(true)
	add_child(ghost_mesh)

func _update_ghost_material(valid: bool) -> void:
	if not ghost_mesh:
		return
	var mi = ghost_mesh.get_child(0) as MeshInstance3D
	if mi:
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		if valid:
			mat.albedo_color = Color(0.2, 0.9, 0.4, 0.45) # Green
		else:
			mat.albedo_color = Color(0.95, 0.2, 0.2, 0.55) # Red
		mi.material_override = mat
