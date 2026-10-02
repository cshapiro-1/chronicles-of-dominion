extends Control
class_name MoodleBadge

@export var moodle_id: String = "famine"
@export var current_tier: int = 1
@export var current_progress: float = 0.0

@onready var panel_bg: PanelContainer = $PanelBG
@onready var lbl_icon: Label = $PanelBG/Margin/HBox/Icon
@onready var bar_progress: ProgressBar = $PanelBG/Margin/HBox/VBox/ProgressBar
@onready var lbl_name: Label = $PanelBG/Margin/HBox/VBox/Name
@onready var tooltip_panel: PanelContainer = $TooltipPanel
@onready var tt_title: Label = $TooltipPanel/Margin/VBox/Title
@onready var tt_tier: Label = $TooltipPanel/Margin/VBox/Tier
@onready var tt_desc: Label = $TooltipPanel/Margin/VBox/Desc
@onready var tt_contagion: Label = get_node_or_null("TooltipPanel/Margin/VBox/Contagion")
@onready var tt_remedy: Label = $TooltipPanel/Margin/VBox/Remedy

func _ready() -> void:
	if tooltip_panel: tooltip_panel.visible = false
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	update_display(current_tier, current_progress)

func update_display(tier: int, progress: float) -> void:
	current_tier = tier
	current_progress = progress
	
	var mm = get_node_or_null("/root/MoodleManager")
	if not mm or not mm.MOODLE_DEFS.has(moodle_id): return
	var def = mm.MOODLE_DEFS[moodle_id]
	
	var clamped_tier = clamp(tier, 1, 4)
	var t_name = def.tier_names[clamped_tier - 1]
	var color = def.tier_colors[clamped_tier - 1]
	
	if lbl_icon: lbl_icon.text = def.icon
	if lbl_name:
		lbl_name.text = t_name.to_upper()
		lbl_name.modulate = color
	if bar_progress:
		bar_progress.value = progress * 100.0
		bar_progress.modulate = color
		
	# Border modulation based on tier
	if panel_bg:
		var sb = panel_bg.get_theme_stylebox("panel")
		if sb and sb is StyleBoxFlat:
			sb.border_color = color
			
	# Update Tooltip
	if tt_title: tt_title.text = "%s %s" % [def.icon, def.title.to_upper()]
	if tt_tier:
		tt_tier.text = "SEVERITY: TIER %d (%s)" % [clamped_tier, t_name.to_upper()]
		tt_tier.modulate = color
	if tt_desc: tt_desc.text = def.descriptions[clamped_tier - 1]
	if tt_contagion:
		tt_contagion.text = "⚠️ CASCADE RISK: %s" % def.get("contagion_risk", "Festers into further unrest.")
	if tt_remedy: tt_remedy.text = "HOW TO RESOLVE: %s" % def.remedy

func play_escalation_pulse() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.18, 1.18), 0.12)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

func _on_mouse_entered() -> void:
	if tooltip_panel:
		tooltip_panel.visible = true

func _on_mouse_exited() -> void:
	if tooltip_panel:
		tooltip_panel.visible = false
