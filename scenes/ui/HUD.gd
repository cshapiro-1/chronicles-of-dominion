extends Control

# Top bar resource labels
@onready var lbl_grain: Label = $TopBar/HBoxResources/Grain/Val
@onready var lbl_grain_delta: Label = $TopBar/HBoxResources/Grain/Delta
@onready var lbl_timber: Label = $TopBar/HBoxResources/Timber/Val
@onready var lbl_stone: Label = $TopBar/HBoxResources/Stone/Val
@onready var lbl_bronze: Label = $TopBar/HBoxResources/Bronze/Val
@onready var lbl_gold: Label = $TopBar/HBoxResources/Gold/Val
@onready var lbl_pop: Label = $TopBar/HBoxResources/Pop/Val

# Estate dials
@onready var dial_altar: Control = $TopBar/DialsPlinth/DialsCenter/DialAltar
@onready var dial_throne: Control = $TopBar/DialsPlinth/DialsCenter/DialThrone
@onready var dial_masses: Control = $TopBar/DialsPlinth/DialsCenter/DialMasses

@onready var lbl_altar_pct: Label = $TopBar/DialsPlinth/DialsCenter/DialAltar/Pct
@onready var lbl_throne_pct: Label = $TopBar/DialsPlinth/DialsCenter/DialThrone/Pct
@onready var lbl_masses_pct: Label = $TopBar/DialsPlinth/DialsCenter/DialMasses/Pct

# Inspector card
@onready var card_title: Label = $BottomLeftCard/VBoxInfo/Title
@onready var card_subtitle: Label = $BottomLeftCard/VBoxInfo/Subtitle
@onready var card_stat1: Label = $BottomLeftCard/VBoxInfo/Stat1
@onready var card_stat2: Label = $BottomLeftCard/VBoxInfo/Stat2
@onready var card_stability: Label = $BottomLeftCard/VBoxInfo/Stability

# Crisis Modal
@onready var crisis_modal: PanelContainer = $CrisisModal
@onready var lbl_crisis_title: Label = $CrisisModal/Margin/VBox/Title
@onready var lbl_crisis_desc: Label = $CrisisModal/Margin/VBox/Description
@onready var btn_crisis_opt1: Button = $CrisisModal/Margin/VBox/HBoxOptions/Option1
@onready var btn_crisis_opt2: Button = $CrisisModal/Margin/VBox/HBoxOptions/Option2

# Notification banner
@onready var notif_panel: PanelContainer = $NotificationBanner
@onready var notif_label: Label = $NotificationBanner/Margin/NotifText

var current_formation: String = "Phalanx"

func _ready() -> void:
	crisis_modal.visible = false
	notif_panel.visible = false
	
	EventBus.economy_updated.connect(_on_economy_updated)
	EventBus.population_updated.connect(_on_population_updated)
	EventBus.estates_updated.connect(_on_estates_updated)
	EventBus.units_selected.connect(_on_units_selected)
	EventBus.crisis_triggered.connect(_on_crisis_triggered)
	EventBus.notification_posted.connect(_on_notification_posted)
	
	_on_economy_updated(EconomyManager.resources, EconomyManager.deltas)
	_on_population_updated(PopulationManager.total_population, PopulationManager.hope, PopulationManager.discontent)
	_on_estates_updated(PoliticsManager.priesthood_loyalty, PoliticsManager.nobility_loyalty, PoliticsManager.commoners_loyalty)
	
	EventBus.post_notification("DOMINION ACTIVE", "Use WASD to pan camera. Hotkeys [1]-[5] command legions.", Color(0.95, 0.82, 0.35))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_on_action_spearmen_pressed()
			KEY_2:
				_on_action_slingers_pressed()
			KEY_3:
				_on_action_chariots_pressed()
			KEY_4, KEY_F:
				_on_action_formation_pressed()
			KEY_5:
				_on_action_raider_wave_pressed()
			KEY_6, KEY_T:
				_on_action_crisis_trigger_pressed()

func _on_economy_updated(res: Dictionary, deltas: Dictionary) -> void:
	lbl_grain.text = "🌾 %d" % int(res.get("Grain", 0.0))
	var gd = deltas.get("Grain", 0.0)
	lbl_grain_delta.text = ("(+%d/m)" % int(gd)) if gd >= 0 else ("(%d/m)" % int(gd))
	
	lbl_timber.text = "🪵 %d" % int(res.get("Timber", 0.0))
	lbl_stone.text = "⛰ %d" % int(res.get("Stone", 0.0))
	lbl_bronze.text = "⚔ %d" % int(res.get("Bronze", 0.0))
	lbl_gold.text = "👑 %d" % int(res.get("Gold", 0.0))
	lbl_pop.text = "👥 %d / %d" % [int(PopulationManager.total_population), int(res.get("Capacity", 6500.0))]

func _on_population_updated(_pop: int, _hope: float, _discontent: float) -> void:
	pass

func _on_estates_updated(p: float, n: float, c: float) -> void:
	lbl_altar_pct.text = "%d%%" % int(p)
	lbl_throne_pct.text = "%d%%" % int(n)
	lbl_masses_pct.text = "%d%%" % int(c)
	
	if dial_altar.has_method("set_percentage"):
		dial_altar.set_percentage(p)
	if dial_throne.has_method("set_percentage"):
		dial_throne.set_percentage(n)
	if dial_masses.has_method("set_percentage"):
		dial_masses.set_percentage(c)

func _on_units_selected(units: Array) -> void:
	if units.is_empty():
		card_title.text = "CITADEL OF UR-KISH"
		card_subtitle.text = "(unselected)"
		card_stat1.text = "PROVINCE POPULATION: 139"
		card_stat2.text = "FORTIFICATION: 1200 / 1200"
		card_stability.text = "REALM STABILITY: High"
	else:
		var u = units[0]
		if is_instance_valid(u) and u.unit_data:
			var count = units.size()
			card_title.text = "%s REGIMENT" % u.unit_data.unit_name.to_upper()
			card_subtitle.text = "Cohort Strength: %d Units | Stance: %s" % [count, current_formation]
			card_stat1.text = "DAMAGE: %d   ARMOR: %d   RANGE: %d" % [int(u.unit_data.damage), int(u.unit_data.armor), int(u.unit_data.attack_range)]
			card_stat2.text = "SPEED: %.1f m/s   UPKEEP: 1.2/m" % u.unit_data.move_speed
			card_stability.text = "COHORT MORALE: Stalwart"

func _on_crisis_triggered(crisis: Resource) -> void:
	lbl_crisis_title.text = "⚡ CRISIS: " + crisis.title.to_upper()
	lbl_crisis_desc.text = crisis.description
	btn_crisis_opt1.text = "DECREE I: " + crisis.options[0]
	btn_crisis_opt2.text = "DECREE II: " + crisis.options[1]
	crisis_modal.visible = true

func _on_crisis_option_pressed(idx: int) -> void:
	crisis_modal.visible = false
	CrisisManager.resolve_crisis(idx)

func _on_notification_posted(title: String, msg: String, col: Color) -> void:
	notif_label.text = "👑 [%s] — %s" % [title.to_upper(), msg]
	notif_panel.modulate = col
	notif_panel.visible = true
	var tween = create_tween()
	tween.tween_interval(4.5)
	tween.tween_property(notif_panel, "modulate:a", 0.0, 0.8)
	tween.tween_callback(func(): notif_panel.visible = false; notif_panel.modulate.a = 1.0)

func _on_action_spearmen_pressed() -> void:
	var ziggurat = get_tree().get_first_node_in_group("Ziggurat")
	if ziggurat and ziggurat.has_method("recruit_unit"):
		ziggurat.recruit_unit("Spearman")

func _on_action_slingers_pressed() -> void:
	var ziggurat = get_tree().get_first_node_in_group("Ziggurat")
	if ziggurat and ziggurat.has_method("recruit_unit"):
		ziggurat.recruit_unit("Slinger")

func _on_action_chariots_pressed() -> void:
	var ziggurat = get_tree().get_first_node_in_group("Ziggurat")
	if ziggurat and ziggurat.has_method("recruit_unit"):
		ziggurat.recruit_unit("Chariot")

func _on_action_formation_pressed() -> void:
	if current_formation == "Phalanx":
		current_formation = "Wedge"
		FormationManager.current_formation_type = FormationManager.FormationType.WEDGE
	elif current_formation == "Wedge":
		current_formation = "Skirmish"
		FormationManager.current_formation_type = FormationManager.FormationType.SKIRMISH_LINE
	else:
		current_formation = "Phalanx"
		FormationManager.current_formation_type = FormationManager.FormationType.PHALANX
		
	EventBus.post_notification("FORMATION DRILL", "Regiments adopted %s tactical drill." % current_formation, Color(0.4, 0.8, 1.0))

func _on_action_raider_wave_pressed() -> void:
	var world = get_tree().root.get_node("Main/World")
	MilitaryManager.spawn_raider_wave(4, Vector3(-35.0, 0.0, -35.0), world)

func _on_action_crisis_trigger_pressed() -> void:
	CrisisManager.trigger_random_crisis()
