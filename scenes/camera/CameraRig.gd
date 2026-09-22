extends Node3D

@export var pan_speed: float = 40.0
@export var zoom_speed: float = 6.0
@export var min_zoom: float = 15.0
@export var max_zoom: float = 140.0
@export var min_pitch: float = -30.0
@export var max_pitch: float = -42.0
@export var damping: float = 12.0

@onready var gimbal: Node3D = $Gimbal
@onready var pitch_arm: Node3D = $Gimbal/PitchArm
@onready var camera: Camera3D = $Gimbal/PitchArm/Camera3D

var target_position: Vector3 = Vector3(0.0, 0.0, 16.0)
var target_zoom: float = 45.0
var target_yaw: float = 0.0

func _ready() -> void:
	global_position = target_position
	camera.position.z = target_zoom
	EventBus.minimap_pan_requested.connect(_on_minimap_pan)

func _process(delta: float) -> void:
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("camera_forward"): input_dir.y -= 1.0
	if Input.is_action_pressed("camera_back"): input_dir.y += 1.0
	if Input.is_action_pressed("camera_left"): input_dir.x -= 1.0
	if Input.is_action_pressed("camera_right"): input_dir.x += 1.0
	
	input_dir = input_dir.normalized()
	
	var forward = -gimbal.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right = gimbal.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	
	var move_vector = (forward * -input_dir.y + right * input_dir.x) * pan_speed * delta * (target_zoom / 26.0)
	target_position += move_vector
	target_position.x = clamp(target_position.x, -90.0, 90.0)
	target_position.z = clamp(target_position.z, -90.0, 90.0)
	
	global_position = global_position.lerp(target_position, damping * delta)
	
	camera.position.z = lerp(camera.position.z, target_zoom, damping * delta)
	var zoom_factor = (camera.position.z - min_zoom) / (max_zoom - min_zoom)
	var target_pitch = lerp(min_pitch, max_pitch, zoom_factor)
	pitch_arm.rotation_degrees.x = lerp(pitch_arm.rotation_degrees.x, target_pitch, damping * delta)
	gimbal.rotation_degrees.y = lerp(gimbal.rotation_degrees.y, target_yaw, damping * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = clamp(target_zoom - zoom_speed, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = clamp(target_zoom + zoom_speed, min_zoom, max_zoom)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		target_yaw -= event.relative.x * 0.4

func _on_minimap_pan(world_pos: Vector3) -> void:
	target_position = Vector3(world_pos.x, 0.0, world_pos.z)
