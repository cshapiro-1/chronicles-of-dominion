extends Control
class_name CampaignMap

@onready var province_container: Control = $Provinces
@onready var inspector_panel: PanelContainer = $ProvinceInspector
@onready var lbl_prov_name: Label = $ProvinceInspector/Margin/VBox/Title
@onready var lbl_prov_owner: Label = $ProvinceInspector/Margin/VBox/Owner
@onready var lbl_prov_pop: Label = $ProvinceInspector/Margin/VBox/Pop
@onready var lbl_prov_order: Label = $ProvinceInspector/Margin/VBox/Order
@onready var lbl_prov_yield: Label = $ProvinceInspector/Margin/VBox/Yields
@onready var btn_tax_low: Button = $ProvinceInspector/Margin/VBox/HBoxTax/BtnLow
@onready var btn_tax_norm: Button = $ProvinceInspector/Margin/VBox/HBoxTax/BtnNorm
@onready var btn_tax_high: Button = $ProvinceInspector/Margin/VBox/HBoxTax/BtnHigh
@onready var btn_build_road: Button = $ProvinceInspector/Margin/VBox/HBoxInfra/BtnRoad
@onready var btn_build_canal: Button = $ProvinceInspector/Margin/VBox/HBoxInfra/BtnCanal
@onready var btn_close_inspector: Button = get_node_or_null("ProvinceInspector/Margin/VBox/BtnClose")

var selected_province_id: String = "ur_kish"

func _ready() -> void:
	visible = false
	var cmm = get_node_or_null("/root/CampaignMapManager")
	if cmm:
		cmm.view_mode_changed.connect(_on_view_mode_changed)
		cmm.province_updated.connect(_on_province_updated)
		
	_create_province_markers()
	_wire_inspector_buttons()
	_update_inspector_display("ur_kish")

func _create_province_markers() -> void:
	if not province_container: return
	for child in province_container.get_children():
		child.queue_free()
		
	var cmm = get_node_or_null("/root/CampaignMapManager")
	if not cmm: return
	
	for p_id in cmm.provinces:
		var p = cmm.provinces[p_id]
		var btn = Button.new()
		btn.name = "ProvBtn_" + p_id
		btn.text = "🏛️ %s" % p.name
		btn.position = p.pos_2d - Vector2(70, 20)
		btn.custom_minimum_size = Vector2(140, 36)
		btn.focus_mode = Control.FOCUS_NONE
		btn.modulate = Color(0.9, 0.95, 1.0) if p.owner == "player" else (Color(1.0, 0.5, 0.5) if p.owner == "enemy" else Color(0.8, 0.8, 0.8))
		
		var captured_id = p_id
		btn.pressed.connect(func(): select_province(captured_id))
		province_container.add_child(btn)

func _draw() -> void:
	var cmm = get_node_or_null("/root/CampaignMapManager")
	if not visible or not cmm: return
	
	# Draw trade road / river lines between provinces
	var connections = [
		["ur_kish", "babylon"],
		["babylon", "nineveh"],
		["babylon", "susa"],
		["ur_kish", "lagash"],
		["lagash", "eridu"]
	]
	
	for conn in connections:
		if cmm.provinces.has(conn[0]) and cmm.provinces.has(conn[1]):
			var p1 = cmm.provinces[conn[0]].pos_2d
			var p2 = cmm.provinces[conn[1]].pos_2d
			# River canal line
			draw_line(p1, p2, Color(0.25, 0.55, 0.75, 0.6), 4.0, true)
			# Road dashed line
			draw_line(p1, p2, Color(0.85, 0.72, 0.45, 0.8), 2.0, false)
		
	# Draw active traveling caravans
	for c in cmm.active_caravans:
		if cmm.provinces.has(c.from) and cmm.provinces.has(c.to):
			var p1 = cmm.provinces[c.from].pos_2d
			var p2 = cmm.provinces[c.to].pos_2d
			var car_pos = p1.lerp(p2, c.progress)
			draw_circle(car_pos, 5.5, Color(1.0, 0.85, 0.25))
			draw_arc(car_pos, 7.0, 0, TAU, 16, Color(0.1, 0.1, 0.1), 1.5)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func _on_view_mode_changed(mode: String) -> void:
	visible = (mode == "STRATEGIC_OVERWORLD")
	if visible:
		_update_inspector_display(selected_province_id)

func _on_province_updated(p_id: String) -> void:
	if p_id == selected_province_id:
		_update_inspector_display(p_id)

func select_province(p_id: String) -> void:
	selected_province_id = p_id
	_update_inspector_display(p_id)

func _update_inspector_display(p_id: String) -> void:
	var cmm = get_node_or_null("/root/CampaignMapManager")
	if not cmm or not cmm.provinces.has(p_id): return
	var p = cmm.provinces[p_id]
	
	if lbl_prov_name: lbl_prov_name.text = p.name.to_upper()
	if lbl_prov_owner: lbl_prov_owner.text = "FACTION: %s" % p.owner.to_upper()
	if lbl_prov_pop: lbl_prov_pop.text = "POPULATION: %d Citizens" % p.population
	if lbl_prov_order:
		lbl_prov_order.text = "PUBLIC ORDER: %d%% (%s Tax)" % [int(p.public_order), p.tax_rate.capitalize()]
		lbl_prov_order.modulate = Color(0.4, 0.95, 0.4) if p.public_order > 70 else (Color(1, 0.8, 0.3) if p.public_order > 40 else Color(1, 0.3, 0.3))
	if lbl_prov_yield:
		lbl_prov_yield.text = "PROVINCIAL YIELD: +%d Grain/m, +%d Gold/m" % [int(p.grain_yield), int(p.gold_yield)]
		
	if btn_build_road:
		btn_build_road.disabled = p.roads_built
		btn_build_road.text = "Road Built" if p.roads_built else "Build Highway (200s)"
	if btn_build_canal:
		btn_build_canal.disabled = p.canals_built
		btn_build_canal.text = "Canal Built" if p.canals_built else "Dig Canal (150w)"

func _wire_inspector_buttons() -> void:
	var cmm = get_node_or_null("/root/CampaignMapManager")
	if not cmm: return
	if btn_tax_low: btn_tax_low.pressed.connect(func(): cmm.set_province_tax(selected_province_id, "low"))
	if btn_tax_norm: btn_tax_norm.pressed.connect(func(): cmm.set_province_tax(selected_province_id, "normal"))
	if btn_tax_high: btn_tax_high.pressed.connect(func(): cmm.set_province_tax(selected_province_id, "high"))
	if btn_build_road: btn_build_road.pressed.connect(func(): cmm.build_provincial_infrastructure(selected_province_id, "roads"))
	if btn_build_canal: btn_build_canal.pressed.connect(func(): cmm.build_provincial_infrastructure(selected_province_id, "canals"))
	if btn_close_inspector: btn_close_inspector.pressed.connect(func(): cmm.set_view_mode("TACTICAL_3D"))
