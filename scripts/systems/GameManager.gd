extends Node

enum GameState { PLAYING, PAUSED, CRISIS_PAUSED, VICTORY, DEFEAT }

var current_state: GameState = GameState.PLAYING
var game_year: int = 2340
var current_season: String = "AUTUMN"
var current_epoch: String = "BRONZE AGE (EPOCH I)"
var game_time_elapsed: float = 0.0
var game_speed: float = 1.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		game_time_elapsed += delta * game_speed

func set_game_state(new_state: GameState) -> void:
	current_state = new_state
	match current_state:
		GameState.PLAYING:
			Engine.time_scale = game_speed
			get_tree().paused = false
		GameState.PAUSED, GameState.CRISIS_PAUSED:
			Engine.time_scale = 0.0
			get_tree().paused = true
		GameState.VICTORY, GameState.DEFEAT:
			Engine.time_scale = 0.2
	EventBus.game_state_changed.emit(current_state)

func set_speed(speed: float) -> void:
	game_speed = speed
	if current_state == GameState.PLAYING:
		Engine.time_scale = game_speed
