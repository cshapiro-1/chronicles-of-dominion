extends CharacterBody3D

@export var unit_data: Resource
@export var team_id: int = 0

enum State { IDLE, MOVING, ATTACKING, DEAD }
var current_state: State = State.IDLE

var current_health: float = 100.0
var target_destination: Vector3 = Vector3.ZERO
var target_enemy: Node = null
var attack_cooldown: float = 0.0
var is_selected: bool = false

@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var sprite_token: Sprite3D = $SpriteToken
@onready var hp_bar: Label3D = $HPBar

func _ready() -> void:
	if unit_data:
		current_health = unit_data.max_health
		_setup_sprite_texture()
	
	target_destination = global_position
	set_selected(false)
	if is_instance_valid(MilitaryManager):
		MilitaryManager.register_unit(self)
	_update_hp_display()

func _setup_sprite_texture() -> void:
	if not sprite_token or not unit_data:
		return
	var uname = unit_data.unit_name
	var tex_path = "res://assets/textures/T_Spearman_Cohort.png"
	if "Slinger" in uname:
		tex_path = "res://assets/textures/T_Slinger_Cohort.png"
	elif "Chariot" in uname:
		tex_path = "res://assets/textures/T_Chariot_Cohort.png"
	elif "Raider" in uname:
		tex_path = "res://assets/textures/T_Slinger_Cohort.png"
		sprite_token.modulate = Color(1.2, 0.55, 0.55)
		
	var tex = load(tex_path)
	if tex:
		sprite_token.texture = tex

func _exit_tree() -> void:
	if is_instance_valid(MilitaryManager):
		MilitaryManager.unregister_unit(self)

func set_selected(selected: bool) -> void:
	is_selected = selected
	selection_ring.visible = is_selected

func move_to_position(pos: Vector3) -> void:
	target_destination = pos
	target_enemy = null
	current_state = State.MOVING

func attack_target(enemy: Node) -> void:
	target_enemy = enemy
	current_state = State.ATTACKING

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
	
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	
	match current_state:
		State.IDLE:
			velocity = velocity.lerp(Vector3.ZERO, 10.0 * delta)
			_scan_for_enemies()
		
		State.MOVING:
			_navigate_to(target_destination, delta)
			if global_position.distance_to(target_destination) < 0.5:
				current_state = State.IDLE
		
		State.ATTACKING:
			if is_instance_valid(target_enemy) and target_enemy.current_state != State.DEAD:
				var dist = global_position.distance_to(target_enemy.global_position)
				var rng = unit_data.attack_range if unit_data else 2.5
				if dist <= rng:
					velocity = velocity.lerp(Vector3.ZERO, 10.0 * delta)
					_perform_attack()
				else:
					_navigate_to(target_enemy.global_position, delta)
			else:
				target_enemy = null
				current_state = State.IDLE
	
	move_and_slide()

func _navigate_to(dest: Vector3, _delta: float) -> void:
	var dir = (dest - global_position)
	dir.y = 0.0
	if dir.length() > 0.1:
		dir = dir.normalized()
		var spd = unit_data.move_speed if unit_data else 5.0
		velocity = dir * spd
	else:
		velocity = Vector3.ZERO

func _perform_attack() -> void:
	if attack_cooldown <= 0.0 and is_instance_valid(target_enemy):
		var spd = unit_data.attack_speed if unit_data else 1.0
		attack_cooldown = 1.0 / max(0.1, spd)
		var dmg = unit_data.damage if unit_data else 15.0
		target_enemy.take_damage(dmg, self)

func take_damage(amount: float, _attacker: Node) -> void:
	var arm = unit_data.armor if unit_data else 2.0
	var effective_damage = max(2.0, amount - arm)
	current_health -= effective_damage
	_update_hp_display()
	
	if sprite_token:
		var tween = create_tween()
		sprite_token.modulate = Color(2.0, 0.4, 0.4)
		tween.tween_property(sprite_token, "modulate", Color(1.0, 1.0, 1.0) if team_id == 0 else Color(1.2, 0.55, 0.55), 0.25)
	
	if current_health <= 0.0:
		die()

func die() -> void:
	current_state = State.DEAD
	set_selected(false)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.35)
	tween.tween_callback(queue_free)

func _update_hp_display() -> void:
	var max_hp = unit_data.max_health if unit_data else 100.0
	hp_bar.text = "%d / %d" % [int(current_health), int(max_hp)]

func _scan_for_enemies() -> void:
	if not is_instance_valid(MilitaryManager):
		return
	for u in MilitaryManager.all_units:
		if is_instance_valid(u) and u.team_id != team_id and u.current_state != State.DEAD:
			if global_position.distance_to(u.global_position) < 14.0:
				target_enemy = u
				current_state = State.ATTACKING
				break
