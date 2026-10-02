extends Control
class_name MoodleContainer

@onready var vbox_moodles: VBoxContainer = $VBoxMoodles

const SCENE_MOODLE_BADGE = preload("res://scenes/ui/components/MoodleBadge.tscn")
var badge_instances: Dictionary = {} # moodle_id -> MoodleBadge instance

func _ready() -> void:
	var mm = get_node_or_null("/root/MoodleManager")
	if mm:
		mm.moodle_added.connect(_on_moodle_added)
		mm.moodle_updated.connect(_on_moodle_updated)
		mm.moodle_removed.connect(_on_moodle_removed)
		mm.moodle_escalated.connect(_on_moodle_escalated)
		
		# Sync any pre-existing active moodles
		for m_id in mm.active_moodles.keys():
			var data = mm.active_moodles[m_id]
			_on_moodle_added(m_id, data.severity)
			_on_moodle_updated(m_id, data.severity, data.progress)

func _on_moodle_added(moodle_id: String, tier: int) -> void:
	if badge_instances.has(moodle_id): return
	
	var badge = SCENE_MOODLE_BADGE.instantiate()
	badge.moodle_id = moodle_id
	badge.current_tier = tier
	badge.current_progress = 0.05
	vbox_moodles.add_child(badge)
	badge_instances[moodle_id] = badge
	
	# Entrance slide & fade animation
	badge.modulate.a = 0.0
	badge.position.x = 40.0
	if is_inside_tree() and badge.is_inside_tree():
		var tw = badge.create_tween()
		tw.set_parallel(true)
		tw.tween_property(badge, "modulate:a", 1.0, 0.25)
		tw.tween_property(badge, "position:x", 0.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		badge.modulate.a = 1.0
		badge.position.x = 0.0

func _on_moodle_updated(moodle_id: String, tier: int, progress: float) -> void:
	if badge_instances.has(moodle_id):
		var badge = badge_instances[moodle_id]
		if is_instance_valid(badge):
			badge.update_display(tier, progress)

func _on_moodle_escalated(moodle_id: String, tier: int) -> void:
	if badge_instances.has(moodle_id):
		var badge = badge_instances[moodle_id]
		if is_instance_valid(badge):
			badge.play_escalation_pulse()

func _on_moodle_removed(moodle_id: String) -> void:
	if not badge_instances.has(moodle_id): return
	var badge = badge_instances[moodle_id]
	badge_instances.erase(moodle_id)
	
	if is_instance_valid(badge) and badge.is_inside_tree():
		var tw = badge.create_tween()
		tw.set_parallel(true)
		tw.tween_property(badge, "modulate:a", 0.0, 0.20)
		tw.tween_property(badge, "position:x", 40.0, 0.20)
		tw.chain().tween_callback(badge.queue_free)
	elif is_instance_valid(badge):
		badge.queue_free()
