extends Control

const ArealUnitSelectionHandler = preload("res://scripts/handlers/ArealUnitSelectionHandler.gd")
const DoubleClickUnitSelectionHandler = preload("res://scripts/handlers/DoubleClickUnitSelectionHandler.gd")
const UnitGroupSelectionHandler = preload("res://scripts/handlers/UnitGroupSelectionHandler.gd")
const MouseClickAnimationsHandler = preload("res://scripts/handlers/MouseClickAnimationsHandler.gd")
const StructurePlacementHandler = preload("res://scripts/handlers/StructurePlacementHandler.gd")
const ActionAttackingWhileInRange = preload("res://scripts/actions/AttackingWhileInRange.gd")
const ActionMoving = preload("res://scripts/actions/Moving.gd")

# Modular Resource Badges
@onready var top_header: TextureRect = $TopMasterHeader
@onready var badge_grain: Control = $TopMasterHeader/ResourceTray/BadgeGrain
@onready var badge_timber: Control = $TopMasterHeader/ResourceTray/BadgeTimber
@onready var badge_stone: Control = $TopMasterHeader/ResourceTray/BadgeStone
@onready var badge_bronze: Control = $TopMasterHeader/ResourceTray/BadgeBronze
@onready var badge_gold: Control = $TopMasterHeader/ResourceTray/BadgeGold
@onready var badge_pop: Control = $TopMasterHeader/ResourceTray/BadgePop

# Inspector console
@onready var inspector_panel: TextureRect = $ProvinceCard
@onready var card_title: Label = $ProvinceCard/VBoxInfo/Title
@onready var card_subtitle: Label = $ProvinceCard/VBoxInfo/Subtitle
@onready var card_stat1: Label = $ProvinceCard/VBoxInfo/Stat1
@onready var card_stat2: Label = $ProvinceCard/VBoxInfo/Stat2
@onready var card_stability: Label = $ProvinceCard/VBoxInfo/Stability

# Command Action Ribbon
@onready var cmd_dock: TextureRect = $CommandDock
@onready var tablet_spear: TextureButton = $CommandDock/HBoxTablets/TabletSpear
@onready var tablet_slinger: TextureButton = $CommandDock/HBoxTablets/TabletSlinger
@onready var tablet_chariot: TextureButton = $CommandDock/HBoxTablets/TabletChariot
@onready var tablet_formation: TextureButton = $CommandDock/HBoxTablets/TabletFormation
@onready var tablet_raiders: TextureButton = $CommandDock/HBoxTablets/TabletRaiders

# Minimap frame
@onready var minimap_console: TextureRect = $MinimapConsole

# Modals
@onready var crisis_modal: PanelContainer = $CrisisModal
@onready var lbl_crisis_title: Label = $CrisisModal/Margin/VBox/Title
@onready var lbl_crisis_desc: Label = $CrisisModal/Margin/VBox/Description
@onready var btn_crisis_opt1: Button = $CrisisModal/Margin/VBox/HBoxOptions/Option1
@onready var btn_crisis_opt2: Button = $CrisisModal/Margin/VBox/HBoxOptions/Option2

@onready var conquest_modal: PanelContainer = $ConquestModal
@onready var btn_raze: Button = $ConquestModal/Margin/VBox/HBoxDecrees/BtnRaze
@onready var btn_consecrate: Button = $ConquestModal/Margin/VBox/HBoxDecrees/BtnConsecrate
@onready var btn_vassalize: Button = $ConquestModal/Margin/VBox/HBoxDecrees/BtnVassalize

# Notification banner
@onready var notif_panel: PanelContainer = $NotificationBanner
@onready var notif_label: Label = $NotificationBanner/Margin/NotifText

# Open RTS Handlers
var selection_box = null
var dbl_click_handler = null
var group_handler = null
var click_anim_handler = null
var placement_handler = null

var selected_units: Array = []
var current_formation: String = "Phalanx"

func _load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	var global_p = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_p):
		var img = Image.load_from_file(global_p)
		if img:
			return ImageTexture.create_from_image(img)
	return null

func _ready() -> void:
	if crisis_modal: crisis_modal.visible = false
	if conquest_modal: conquest_modal.visible = false
	if notif_panel: notif_panel.visible = false
	
	# Instantiate Open RTS Handlers
	selection_box = ArealUnitSelectionHandler.new()
	selection_box.set_anchors_preset(PRESET_FULL_RECT)
	add_child(selection_box)
	
	dbl_click_handler = DoubleClickUnitSelectionHandler.new()
	add_child(dbl_click_handler)
	
	group_handler = UnitGroupSelectionHandler.new()
	add_child(group_handler)
	
	click_anim_handler = MouseClickAnimationsHandler.new()
	get_tree().root.get_node("Main/World").add_child(click_anim_handler)
	
	placement_handler = StructurePlacementHandler.new()
	get_tree().root.get_node("Main/World").add_child(placement_handler)
	
	_apply_hud_textures()
	
	EventBus.economy_updated.connect(_on_economy_updated)
	EventBus.population_updated.connect(_on_population_updated)
	EventBus.estates_updated.connect(_on_estates_updated)
	EventBus.units_selected.connect(_on_units_selected)
	EventBus.crisis_triggered.connect(_on_crisis_triggered)
	EventBus.notification_posted.connect(_on_notification_posted)
	EventBus.conquest_victory_triggered.connect(_on_conquest_victory_triggered)
	
	_on_economy_updated(EconomyManager.resources, EconomyManager.deltas)
	_on_population_updated(PopulationManager.total_population, PopulationManager.hope, PopulationManager.discontent)
	_on_estates_updated(PoliticsManager.priesthood_loyalty, PoliticsManager.nobility_loyalty, PoliticsManager.commoners_loyalty)
	
	_wire_tablets()
	_wire_conquest_buttons()
	_wire_crisis_buttons()
	
	EventBus.post_notification("DOMINION ACTIVE", "Campaign Initialized. Marquee drag selects units, RMB orders moves/attacks.", Color(0.95, 0.82, 0.35))

func _wire_crisis_buttons() -> void:
	if btn_crisis_opt1:
		btn_crisis_opt1.pressed.connect(func():
			if crisis_modal: crisis_modal.visible = false
			get_tree().paused = false
			CrisisManager.resolve_crisis(0)
		)
	if btn_crisis_opt2:
		btn_crisis_opt2.pressed.connect(func():
			if crisis_modal: crisis_modal.visible = false
			get_tree().paused = false
			CrisisManager.resolve_crisis(1)
		)

func _apply_hud_textures() -> void:
	var tex_top = _load_tex("res://assets/ui/T_HUD_TopHeader_Master.png")
	if tex_top and top_header:
		top_header.texture = tex_top

	var tex_card = _load_tex("res://assets/ui/T_HUD_ProvinceCard_Master.png")
	if tex_card and inspector_panel:
		inspector_panel.texture = tex_card

	var tex_cmd = _load_tex("res://assets/ui/T_HUD_CommandDock_Master.png")
	if tex_cmd and cmd_dock:
		cmd_dock.texture = tex_cmd

	var tex_map = _load_tex("res://assets/ui/T_HUD_MinimapFrame_Master.png")
	if tex_map and minimap_console:
		minimap_console.texture = tex_map

	var tex_spear = _load_tex("res://assets/ui/btn_action_spear.png")
	var tex_bow = _load_tex("res://assets/ui/btn_action_bow.png")
	var tex_chariot = _load_tex("res://assets/ui/btn_action_chariot.png")
	var tex_phalanx = _load_tex("res://assets/ui/btn_action_phalanx.png")
	var tex_decree = _load_tex("res://assets/ui/btn_action_decree.png")

	if tablet_spear: tablet_spear.set_icon_texture(tex_spear)
	if tablet_slinger: tablet_slinger.set_icon_texture(tex_bow)
	if tablet_chariot: tablet_chariot.set_icon_texture(tex_chariot)
	if tablet_formation: tablet_formation.set_icon_texture(tex_phalanx)
	if tablet_raiders: tablet_raiders.set_icon_texture(tex_decree)

func _wire_tablets() -> void:
	if tablet_spear: tablet_spear.pressed.connect(func(): _spawn_unit("spearman"))
	if tablet_slinger: tablet_slinger.pressed.connect(func(): _spawn_unit("archer"))
	if tablet_chariot: tablet_chariot.pressed.connect(func(): _spawn_unit("chariot"))
	if tablet_formation: tablet_formation.pressed.connect(_toggle_formation)
	if tablet_raiders: tablet_raiders.pressed.connect(_trigger_decree_council)

func _wire_conquest_buttons() -> void:
	if btn_raze: btn_raze.pressed.connect(func(): _resolve_conquest("raze"))
	if btn_consecrate: btn_consecrate.pressed.connect(func(): _resolve_conquest("consecrate"))
	if btn_vassalize: btn_vassalize.pressed.connect(func(): _resolve_conquest("vassalize"))

var rmb_press_pos: Vector2 = Vector2.ZERO
var selected_building: Building = null

func _unhandled_input(event: InputEvent) -> void:
	# Marquee Drag Selection / Single Click Selection
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if placement_handler and placement_handler.is_placing:
					placement_handler.confirm_placement()
					return
				if selection_box: selection_box.start_drag(event.position)
			else:
				if selection_box:
					var units_found = selection_box.end_drag()
					if not units_found.is_empty():
						_select_units(units_found)
						_select_building(null)
					else:
						# Single Click Raycast Selection
						var camera = get_viewport().get_camera_3d()
						if camera:
							var from = camera.project_ray_origin(event.position)
							var to = from + camera.project_ray_normal(event.position) * 1000.0
							var space = camera.get_world_3d().direct_space_state
							var query = PhysicsRayQueryParameters3D.create(from, to)
							var result = space.intersect_ray(query)
							if result and result.collider:
								var col = result.collider
								if col.is_in_group("Units") and col.get("team_id") == 0:
									_select_units([col])
									_select_building(null)
								elif col is Building or col.is_in_group("Buildings") or col.is_in_group("PlayerBuildings"):
									_select_units([])
									_select_building(col)
								else:
									_select_units([])
									_select_building(null)
							else:
								_select_units([])
								_select_building(null)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if placement_handler and placement_handler.is_placing:
					placement_handler.cancel_placement()
					return
				rmb_press_pos = event.position
				rmb_is_dragging = false
			else:
				if rmb_is_dragging:
					_issue_facing_move_order(rmb_press_pos, event.position)
				elif selected_building and selected_units.is_empty():
					var r_pos = _screen_to_ground(event.position)
					selected_building.set_rally_point(r_pos)
					if click_anim_handler: click_anim_handler.spawn_order_ring(r_pos, 0)
				else:
					_issue_right_click_order(event.position)
				rmb_is_dragging = false
	elif event is InputEventMouseMotion:
		if selection_box and selection_box.is_dragging:
			selection_box.update_drag(event.position)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and not selected_units.is_empty():
			if (event.position - rmb_press_pos).length() > 14.0:
				rmb_is_dragging = true
		if placement_handler and placement_handler.is_placing:
			var world_pos = _screen_to_ground(event.position)
			placement_handler.update_ghost_position(world_pos)
			
	# Control Groups & Hotkeys
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.is_ctrl_pressed() and event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var grp_idx = event.keycode - KEY_0
			if group_handler: group_handler.bind_group(grp_idx, selected_units)
			EventBus.post_notification("CONTROL GROUP", "Group %d assigned (%d units)" % [grp_idx, selected_units.size()], Color(0.8, 0.9, 1.0))
		elif event.keycode >= KEY_1 and event.keycode <= KEY_5 and not event.is_ctrl_pressed():
			match event.keycode:
				KEY_1:
					if selected_building and selected_building.has_method("recruit_unit"):
						selected_building.recruit_unit("spearman")
					else:
						_spawn_unit("spearman")
				KEY_2:
					if selected_building and selected_building.has_method("recruit_unit"):
						selected_building.recruit_unit("archer")
					else:
						_spawn_unit("archer")
				KEY_3:
					if selected_building and selected_building.has_method("recruit_unit"):
						selected_building.recruit_unit("chariot")
					else:
						_spawn_unit("chariot")
				KEY_4: _toggle_formation()
				KEY_5: _trigger_decree_council()
		# Construction Placement Shortcuts
		elif event.keycode == KEY_B:
			start_structure_placement("barracks")
		elif event.keycode == KEY_N:
			start_structure_placement("granary")
		elif event.keycode == KEY_H:
			start_structure_placement("house")
		elif event.keycode == KEY_M:
			start_structure_placement("bazaar")
		elif event.keycode == KEY_F:
			start_structure_placement("chariot_foundry")
		elif event.keycode == KEY_ESCAPE:
			if placement_handler and placement_handler.is_placing:
				placement_handler.cancel_placement()
		elif event.keycode == KEY_G:
			_spawn_hostile_raider()

func start_structure_placement(type_key: String) -> void:
	if placement_handler:
		placement_handler.start_placement(type_key)
		EventBus.post_notification(
			"PLACING STRUCTURE",
			"LMB to build %s. RMB or ESC to cancel." % type_key.capitalize(),
			Color(0.3, 0.85, 1.0)
		)

func _select_building(b: Building) -> void:
	if selected_building and is_instance_valid(selected_building):
		selected_building.deselect()
	selected_building = b
	if selected_building and is_instance_valid(selected_building):
		selected_building.select()
		card_title.text = selected_building.building_name.to_upper()
		var stat_txt = "Operational" if selected_building.state == Building.State.COMPLETED else "Under Construction (%d%%)" % int(selected_building.construction_progress * 100.0)
		card_subtitle.text = "%s Quarter — %s" % [selected_building.building_category, stat_txt]
		card_stat1.text = "INTEGRITY: %d / %d" % [int(selected_building.current_health), int(selected_building.max_health)]
		card_stat2.text = "OUTPUT: +%d Gold/s, +%d Grain/s" % [int(selected_building.gold_production), int(selected_building.grain_production)]
		card_stability.text = "CAPACITY: +%d Housing" % selected_building.housing_provided
	else:
		card_title.text = "CITADEL OF UR-KISH"
		card_subtitle.text = "Sovereign Seat of the God-King"
		card_stat1.text = "PROVINCE POPULATION: %d" % PopulationManager.total_population
		card_stat2.text = "FORTIFICATION: 1200 / 1200"
		card_stability.text = "REALM STABILITY: High (92%)"


func _select_units(units: Array) -> void:
	for u in selected_units:
		if is_instance_valid(u) and u.has_method("deselect"):
			u.deselect()
	selected_units = units
	for u in selected_units:
		if is_instance_valid(u):
			if u.has_method("select"):
				u.select()
			u.set("active_formation", current_formation)
	EventBus.units_selected.emit(selected_units)

func _issue_facing_move_order(screen_start: Vector2, screen_end: Vector2) -> void:
	if selected_units.is_empty(): return
	var start_pos = _screen_to_ground(screen_start)
	var end_pos = _screen_to_ground(screen_end)
	var facing_vec = (end_pos - start_pos)
	facing_vec.y = 0.0
	
	if facing_vec.length() < 0.4:
		_issue_right_click_order(screen_start)
		return
		
	var facing_yaw = atan2(facing_vec.x, facing_vec.z)
	if click_anim_handler: click_anim_handler.spawn_order_ring(start_pos, 0)
	
	var count = selected_units.size()
	for i in range(count):
		var u = selected_units[i]
		if is_instance_valid(u):
			var base_offset = _compute_formation_offset(i, count)
			var rotated_offset = base_offset.rotated(Vector3.UP, facing_yaw)
			if u.has_method("set_target_destination"):
				u.set_target_destination(start_pos + rotated_offset, facing_yaw, true)
				
	EventBus.post_notification("FORMATION DEPLOYED", "%s battle line oriented facing target." % current_formation, Color(0.45, 0.95, 0.55))

func _issue_right_click_order(screen_pos: Vector2) -> void:
	if selected_units.is_empty(): return
	var camera = get_viewport().get_camera_3d()
	if not camera: return
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 1000.0
	var space = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space.intersect_ray(query)
	
	var target_pos = Vector3.ZERO
	var target_collider = null
	
	if result:
		target_pos = result.position
		target_collider = result.collider
	else:
		var plane = Plane(Vector3.UP, 0.0)
		var hit = plane.intersects_ray(from, camera.project_ray_normal(screen_pos))
		if hit != null:
			target_pos = hit
		else:
			return
		
	# Check if clicking an enemy unit or enemy building
	var is_enemy = false
	if target_collider and ((target_collider.is_in_group("Units") and target_collider.get("team_id") == 1) or target_collider.is_in_group("EnemyBuildings") or target_collider.is_in_group("Destructible")):
		is_enemy = true
		
	if is_enemy:
		if click_anim_handler: click_anim_handler.spawn_order_ring(target_pos, 1) # Red Attack
		for u in selected_units:
			if is_instance_valid(u) and u.has_method("attack_target"):
				u.attack_target(target_collider)
		EventBus.post_notification("ATTACK ORDER", "Engaging target with %d regiments!" % selected_units.size(), Color(1.0, 0.3, 0.3))
	else:
		if click_anim_handler: click_anim_handler.spawn_order_ring(target_pos, 0) # Green Move
		var count = selected_units.size()
		for i in range(count):
			var u = selected_units[i]
			if is_instance_valid(u):
				var offset = _compute_formation_offset(i, count)
				if u.has_method("move_to_position"):
					u.move_to_position(target_pos + offset)
				elif u.has_method("set_target_destination"):
					u.set_target_destination(target_pos + offset)

func _compute_formation_offset(idx: int, total: int) -> Vector3:
	if total <= 1:
		return Vector3.ZERO
	match current_formation:
		"Phalanx":
			# 3-column tight combat ranks
			var cols = 3
			var row = idx / cols
			var col = idx % cols
			return Vector3((col - 1.0) * 3.4, 0, (row - 0.5) * 3.4)
		"Wedge":
			# Arrowhead spearhead
			if idx == 0:
				return Vector3(0, 0, -2.5)
			var side = 1.0 if idx % 2 == 1 else -1.0
			var rank = (idx + 1) / 2
			return Vector3(side * rank * 2.6, 0, rank * 2.8)
		"Skirmish":
			# Wide firing line
			return Vector3((idx - (total - 1) * 0.5) * 4.2, 0, 0)
		_:
			return Vector3.ZERO

func _screen_to_ground(screen_pos: Vector2) -> Vector3:
	var camera = get_viewport().get_camera_3d()
	if not camera: return Vector3.ZERO
	var plane = Plane(Vector3.UP, 0.0)
	var from = camera.project_ray_origin(screen_pos)
	var dir = camera.project_ray_normal(screen_pos)
	var hit = plane.intersects_ray(from, dir)
	return hit if hit != null else Vector3.ZERO

func _spawn_unit(type: String) -> void:
	var costs = {
		"spearman": {"Grain": 50, "Bronze": 20},
		"archer": {"Grain": 35, "Timber": 15},
		"chariot": {"Grain": 120, "Bronze": 60}
	}
	if not costs.has(type): return
	var cost = costs[type]
	for res in cost:
		if EconomyManager.resources.get(res, 0) < cost[res]:
			EventBus.post_notification("INSUFFICIENT RESOURCES", "Need %d %s to muster %s" % [cost[res], res, type.capitalize()], Color(0.95, 0.3, 0.3))
			return
	
	for res in cost:
		EconomyManager.resources[res] -= cost[res]
	EventBus.economy_updated.emit(EconomyManager.resources, EconomyManager.deltas)
		
	var unit_scene = load("res://scenes/units/Unit.tscn")
	if unit_scene:
		var u = unit_scene.instantiate()
		u.unit_type = type
		u.team_id = 0
		var spawn_x = -4.0 + (randf() - 0.5) * 6.0
		var spawn_z = 24.0 + (randf() - 0.5) * 6.0
		u.position = Vector3(spawn_x, 0.0, spawn_z)
		get_tree().root.get_node("Main/World").add_child(u)
		EventBus.post_notification("LEGION MUSTERED", "%s deployed to the South Gate" % type.capitalize(), Color(0.48, 0.95, 0.52))

func _spawn_hostile_raider() -> void:
	var unit_scene = load("res://scenes/units/Unit.tscn")
	if unit_scene:
		var u = unit_scene.instantiate()
		u.unit_type = "raider"
		u.team_id = 1
		# Spawn 25m south of player positions
		u.position = Vector3(randf_range(-10.0, 10.0), 0.0, 42.0)
		get_tree().root.get_node("Main/World").add_child(u)
		EventBus.post_notification("HOSTILE INCURSION!", "Nomadic Desert Raiders advancing from the south hills!", Color(1.0, 0.25, 0.25))

func _toggle_formation() -> void:
	if current_formation == "Phalanx":
		current_formation = "Wedge"
	elif current_formation == "Wedge":
		current_formation = "Skirmish"
	else:
		current_formation = "Phalanx"
	for u in selected_units:
		if is_instance_valid(u):
			u.set("active_formation", current_formation)
	EventBus.post_notification("FORMATION DRILL", "Active Battle Order: %s" % current_formation, Color(0.95, 0.85, 0.35))

func _trigger_decree_council() -> void:
	CrisisManager.trigger_random_crisis()

func _on_conquest_victory_triggered(_citadel_name: String = "", _spoils: Dictionary = {}) -> void:
	if conquest_modal:
		conquest_modal.visible = true
		get_tree().paused = true

func _resolve_conquest(choice: String) -> void:
	if conquest_modal:
		conquest_modal.visible = false
		get_tree().paused = false
	match choice:
		"raze":
			EconomyManager.resources["Gold"] = EconomyManager.resources.get("Gold", 0) + 800
			PoliticsManager.adjust_loyalty("commoners", -25)
			PoliticsManager.adjust_loyalty("nobility", 20)
			EventBus.post_notification("CITADEL RAZED", "Plundered 800 Gold. Foreign population dispersed.", Color(1.0, 0.4, 0.2))
		"consecrate":
			PoliticsManager.adjust_loyalty("priesthood", 25)
			PopulationManager.total_population += 15
			EventBus.post_notification("TEMPLE CONSECRATED", "High Priesthood loyalty bolstered.", Color(0.4, 0.8, 1.0))
		"vassalize":
			EconomyManager.deltas["Gold"] = EconomyManager.deltas.get("Gold", 0) + 35
			PoliticsManager.adjust_loyalty("nobility", 15)
			EventBus.post_notification("TRIBUTARY SUBJUGATED", "Monthly tribute established: +35 Gold/m", Color(0.95, 0.85, 0.3))

func _on_economy_updated(res: Dictionary, deltas: Dictionary) -> void:
	var g = int(res.get("Grain", res.get("grain", 1420)))
	var dg = int(deltas.get("Grain", deltas.get("grain", 45)))
	var t = int(res.get("Timber", res.get("timber", 850)))
	var dt = int(deltas.get("Timber", deltas.get("timber", 18)))
	var s = int(res.get("Stone", res.get("stone", 1200)))
	var ds = int(deltas.get("Stone", deltas.get("stone", 25)))
	var b = int(res.get("Bronze", res.get("bronze", 650)))
	var db = int(deltas.get("Bronze", deltas.get("bronze", 12)))
	var au = int(res.get("Gold", res.get("gold", 5200)))
	var dau = int(deltas.get("Gold", deltas.get("gold", 80)))
	
	if badge_grain: badge_grain.set_amount(g, dg)
	if badge_timber: badge_timber.set_amount(t, dt)
	if badge_stone: badge_stone.set_amount(s, ds)
	if badge_bronze: badge_bronze.set_amount(b, db)
	if badge_gold: badge_gold.set_amount(au, dau)

func _on_population_updated(pop: int, _hope: float, _disc: float) -> void:
	if badge_pop: badge_pop.set_amount(pop, 0)
	if card_stat1: card_stat1.text = "PROVINCE POPULATION: %d" % pop

func _on_estates_updated(_altar: float, _throne: float, _masses: float) -> void:
	pass

func _on_units_selected(units: Array) -> void:
	if units.is_empty():
		card_title.text = "CITADEL OF UR-KISH"
		card_subtitle.text = "Sovereign Seat of the God-King"
		card_stat1.text = "PROVINCE POPULATION: %d" % PopulationManager.total_population
		card_stat2.text = "FORTIFICATION: 1200 / 1200"
		card_stability.text = "REALM STABILITY: High"
	else:
		var u = units[0]
		card_title.text = "LEGION BATTALION"
		var utype = u.get("unit_type")
		card_subtitle.text = "%s Regiment (Rank I)" % (str(utype).capitalize() if utype else "Spearman")
		card_stat1.text = "SOLDIERS: %d in formation" % units.size()
		card_stat2.text = "READINESS: 100%"
		card_stability.text = "ORDER: %s" % current_formation

func _on_crisis_triggered(crisis_data: Resource) -> void:
	if not crisis_modal or not crisis_data: return
	lbl_crisis_title.text = crisis_data.get("title") if "title" in crisis_data else "IMPERIAL CRISIS"
	lbl_crisis_desc.text = crisis_data.get("description") if "description" in crisis_data else ""
	var opts = crisis_data.get("options")
	if opts and opts.size() > 0:
		btn_crisis_opt1.text = opts[0]
		btn_crisis_opt2.text = opts[1] if opts.size() > 1 else "Dismiss"
	crisis_modal.visible = true
	get_tree().paused = true

func _on_notification_posted(title: String, body: String, _col: Color) -> void:
	if notif_label:
		notif_label.text = "[%s] %s" % [title, body]
	if notif_panel:
		notif_panel.visible = true
