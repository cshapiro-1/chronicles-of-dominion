extends Node

@onready var world: Node3D = $World
@onready var camera_rig: Node3D = $CameraRig
@onready var hud: Control = $UI/HUD

var ai_commander: SimpleClairvoyantAI = null

func _ready() -> void:
	# Initialize AI Rival Commander
	ai_commander = SimpleClairvoyantAI.new()
	ai_commander.name = "RivalCommanderAI"
	add_child(ai_commander)
	
	EventBus.notification_posted.emit("CHRONICLES OF DOMINION", "Bronze Age Campaign Initialized. Ziggurat of Ur-Kish active.", Color(1, 0.85, 0.3))
	call_deferred("_auto_capture_screenshot")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			SaveManager.save_game()
		elif event.keycode == KEY_F9:
			SaveManager.load_game()
		elif event.keycode == KEY_TAB:
			CampaignMapManager.toggle_view_mode()

func _auto_capture_screenshot() -> void:
	for i in range(35):
		await get_tree().process_frame
	var vp = get_viewport()
	if vp:
		var img = vp.get_texture().get_image()
		if img:
			var save_path = "C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/godot_live_render.png"
			img.save_png(save_path)
			print(">>> CAPTURED GODOT LIVE RENDER TO: ", save_path)
