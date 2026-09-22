extends Node3D

@export var asset_path: String = "res://assets/generated/pending_approval/ziggurat_tier_01.tscn"

@onready var pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var asset_container: Node3D = $AssetContainer
@onready var info_label: Label = $UI/Panel/VBoxContainer/InfoLabel
@onready var btn_auto_rotate: CheckButton = $UI/Panel/VBoxContainer/AutoRotateBtn

var auto_rotate: bool = true
var rotate_speed: float = 0.3
var is_dragging: bool = false
var is_panning: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var target_zoom: float = 55.0
var current_zoom: float = 55.0

func _ready() -> void:
	load_asset(asset_path)
	setup_ui()

func load_asset(path: String) -> void:
	for child in asset_container.get_children():
		child.queue_free()
	
	if ResourceLoader.exists(path):
		var scene: PackedScene = load(path)
		if scene:
			var inst = scene.instantiate()
			asset_container.add_child(inst)
			print("AssetViewer: Loaded " + path)
			if info_label:
				info_label.text = "Asset: " + path.get_file() + "\nStatus: PENDING APPROVAL\nControls: LMB Orbit | RMB Pan | Wheel Zoom"
	else:
		if info_label:
			info_label.text = "Asset not found: " + path

func setup_ui() -> void:
	if btn_auto_rotate:
		btn_auto_rotate.toggled.connect(func(pressed): auto_rotate = pressed)

func _process(delta: float) -> void:
	if auto_rotate and not is_dragging:
		pivot.rotate_y(rotate_speed * delta)
	
	# Smooth zoom
	current_zoom = lerp(current_zoom, target_zoom, delta * 10.0)
	camera.position.z = current_zoom

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			last_mouse_pos = event.position
			if is_dragging and btn_auto_rotate:
				btn_auto_rotate.button_pressed = false
				auto_rotate = false
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			is_panning = event.pressed
			last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom - 4.0, 10.0, 120.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom + 4.0, 10.0, 120.0)
			
	elif event is InputEventMouseMotion:
		var delta = event.position - last_mouse_pos
		last_mouse_pos = event.position
		
		if is_dragging:
			pivot.rotate_y(-delta.x * 0.006)
			var pitch = pivot.rotation.x - delta.y * 0.006
			pivot.rotation.x = clamp(pitch, -deg_to_rad(85), deg_to_rad(10))
		elif is_panning:
			var pan_speed = current_zoom * 0.001
			pivot.position += -pivot.transform.basis.x * delta.x * pan_speed + pivot.transform.basis.y * delta.y * pan_speed

	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: # Front View
				pivot.rotation_degrees = Vector3(-15, 0, 0)
			KEY_2: # Isometric 3/4 View
				pivot.rotation_degrees = Vector3(-35, 45, 0)
			KEY_3: # Top Down
				pivot.rotation_degrees = Vector3(-89, 0, 0)
			KEY_SPACE: # Toggle Rotation
				auto_rotate = !auto_rotate
				if btn_auto_rotate:
					btn_auto_rotate.button_pressed = auto_rotate
			KEY_ESCAPE:
				get_tree().quit()
