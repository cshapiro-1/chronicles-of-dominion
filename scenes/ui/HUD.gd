extends Control

# Top bar resource labels
@onready var lbl_grain: Label = $TopBar/HBoxLeft/ResGrain/HBox/VBox/Val
@onready var lbl_grain_delta: Label = $TopBar/HBoxLeft/ResGrain/HBox/VBox/Delta
@onready var lbl_timber: Label = $TopBar/HBoxLeft/ResTimber/HBox/VBox/Val
@onready var lbl_stone: Label = $TopBar/HBoxLeft/ResStone/HBox/VBox/Val
@onready var lbl_bronze: Label = $TopBar/HBoxLeft/ResBronze/HBox/VBox/Val
@onready var lbl_gold: Label = $TopBar/HBoxLeft/ResGold/HBox/VBox/Val
@onready var lbl_pop: Label = $TopBar/HBoxLeft/ResPop/HBox/VBox/Val

# Estate dials
@onready var dial_altar: Control = $TopBar/HBoxCenter/DialAltar
@onready var dial_throne: Control = $TopBar/HBoxCenter/DialThrone
@onready var dial_masses: Control = $TopBar/HBoxCenter/DialMasses

@onready var lbl_altar_pct: Label = $TopBar/HBoxCenter/DialAltar/Pct
@onready var lbl_throne_pct: Label = $TopBar/HBoxCenter/DialThrone/Pct
@onready var lbl_masses_pct: Label = $TopBar/HBoxCenter/DialMasses/Pct

# Morale bars
@onready var bar_hope: ProgressBar = $TopBar/HBoxRight/Morale/HBoxH/HopeBar
@onready var bar_discontent: ProgressBar = $TopBar/HBoxRight/Morale/HBoxD/DiscontentBar

# Inspector card
@onready var card_icon: Label = $BottomLeftCard/Margin/HBox/IconBox/IconLabel
@onready var card_title: Label = $BottomLeftCard/Margin/HBox/VBoxInfo/Title
@onready var card_subtitle: Label = $BottomLeftCard/Margin/HBox/VBoxInfo/Subtitle
@onready var card_stat1: Label = $BottomLeftCard/Margin/HBox/VBoxInfo/Stat1
@onready var card_stat2: Label = $BottomLeftCard/Margin/HBox/VBoxInfo/Stat2
@onready var card_hp_bar: ProgressBar = $BottomLeftCard/Margin/HBox/VBoxInfo/HpBar

# Crisis Modal
@onready var crisis_modal: PanelContainer = $CrisisModal
@onready var lbl_crisis_title: Label = $CrisisModal/Margin/VBox/Title
@onready var lbl_crisis_desc: Label = $CrisisModal/Margin/VBox/Description
@onready var btn_crisis_opt1: Button = $CrisisModal/Margin/VBox/HBoxOptions/Option1
@onready var btn_crisis_opt2: Button = $CrisisModal/Margin/VBox/HBoxOptions/Option2

# Notification banner
@onready var notif_panel: PanelContainer = $NotificationBanner
@onready var notif_label: Label = $NotificationBanner/Margin/NotifText

# Formation state
var current_formation: String = "Phalanx"
@onready var btn_formation: Button = $ActionRibbon/HBoxButtons/BtnFormation

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
	
	# Post initial welcome notification
	EventBus.post_notification("DOMINION ACTIVE", "Command your bronze age legions with Right-Click. Recruit reinforcements at the Ziggurat.", Color(0.95, 0.82, 0.35))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Q:
				_on_action_spearmen_pressed()
			KEY_W:
				_on_action_slingers_pressed()
			KEY_E:
				_on_action_chariots_pressed()
			KEY_F:
				_on_action_formation_pressed()
			KEY_R:
				_on_action_raider_wave_pressed()
			KEY_T:
				_on_action_crisis_trigger_pressed()


func _on_economy_updated(res: Dictionary, deltas: Dictionary) -> void:
	lbl_grain.text = "%d" % int(res.get("Grain", 0.0))
	var gd = deltas.get("Grain", 0.0)
	lbl_grain_delta.text = ("+%d/m" % int(gd)) if gd >= 0 else ("%d/m" % int(gd))
	lbl_grain_delta.modulate = Color(0.4, 0.9, 0.4) if gd >= 0 else Color(0.95, 0.3, 0.3)
	
	lbl_timber.text = "%d" % int(res.get("Timber", 0.0))
	lbl_stone.text = "%d" % int(res.get("Stone", 0.0))
	lbl_bronze.text = "%d" % int(res.get("Bronze", 0.0))
	lbl_gold.text = "%d" % int(res.get("Gold", 0.0))
	lbl_pop.text = "%d / %d" % [int(PopulationManager.total_population), int(res.get("Capacity", 6500.0))]

func _on_population_updated(pop: int, hope: float, discontent: float) -> void:
	bar_hope.value = hope * 100.0
	bar_discontent.value = discontent * 100.0
	if discontent > 0.65:
		bar_discontent.modulate = Color(1.2, 0.3, 0.3, 1.0)
	else:
		bar_discontent.modulate = Color(1.0, 1.0, 1.0, 1.0)

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
		card_icon.text = "🏛"
		card_title.text = "CITADEL OF UR-KISH"
		card_subtitle.text = "Royal Capital (Tier 1 Megalith)"
		card_stat1.text = "🌾 Food Buffer: 90 Days   👥 Manpower: 100%"
		card_stat2.text = "🛡 Citadel Defense: 1,500 / 1,500   👑 Stability: 85%"
		card_hp_bar.value = 100.0
		card_hp_bar.modulate = Color(0.95, 0.8, 0.3)
	else:
		var u = units[0]
		if is_instance_valid(u) and u.unit_data:
			var count = units.size()
			card_icon.text = "⚔" if u.unit_data.unit_name != "Chariot" else "🐎"
			card_title.text = "%s COHORT (%d Units)" % [u.unit_data.unit_name.to_upper(), count]
			card_subtitle.text = "Stance: %s Formation | Morale: High" % current_formation
			card_stat1.text = "⚔ Damage: %d   🛡 Armor: %d   🏹 Range: %d" % [int(u.unit_data.damage), int(u.unit_data.armor), int(u.unit_data.attack_range)]
			card_stat2.text = "⚡ Speed: %.1f m/s   🌾 Upkeep: 1.2/m" % u.unit_data.move_speed
			var max_hp = u.unit_data.max_health
			var cur_hp = u.current_health
			card_hp_bar.value = (cur_hp / max_hp) * 100.0
			card_hp_bar.modulate = Color(0.3, 0.85, 0.4) if cur_hp > (max_hp * 0.5) else Color(0.95, 0.3, 0.3)

func _on_crisis_triggered(crisis: Resource) -> void:
	lbl_crisis_title.text = "⚡ CRISIS: " + crisis.title.to_upper()
	lbl_crisis_desc.text = crisis.description
	btn_crisis_opt1.text = "OPTION I: " + crisis.options[0]
	btn_crisis_opt2.text = "OPTION II: " + crisis.options[1]
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
		
	btn_formation.text = "[F] Drill\n(%s)" % current_formation
	EventBus.post_notification("FORMATION DRILL", "Regiments adopted %s tactical drill." % current_formation, Color(0.4, 0.8, 1.0))

func _on_action_raider_wave_pressed() -> void:
	var world = get_tree().root.get_node("Main/World")
	MilitaryManager.spawn_raider_wave(4, Vector3(-35.0, 0.0, -35.0), world)

func _on_action_crisis_trigger_pressed() -> void:
	CrisisManager.trigger_random_crisis()
