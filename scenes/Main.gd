extends Node

@onready var world: Node3D = $World
@onready var camera_rig: Node3D = $CameraRig
@onready var hud: Control = $UI/HUD
@onready var selection_box: Control = $UI/SelectionBox

func _ready() -> void:
	selection_box.camera = camera_rig.camera
	EventBus.notification_posted.emit("CHRONICLES OF DOMINION", "Bronze Age Campaign Initialized. Ziggurat of Ur-Kish active.", Color(1, 0.85, 0.3))
