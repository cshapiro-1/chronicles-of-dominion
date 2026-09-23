extends Node

var audio_players: Array[AudioStreamPlayer] = []
const POOL_SIZE = 8

func _ready() -> void:
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		add_child(p)
		audio_players.append(p)
		
	EventBus.notification_posted.connect(_on_notification_sound)

func play_sfx(sound_type: String) -> void:
	var player = _get_available_player()
	if not player: return
	
	# Generate procedural audio generator for lightweight native sound feedback
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 22050
	gen.buffer_length = 0.25
	player.stream = gen
	player.play()
	
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not playback: return
	
	match sound_type:
		"order":
			# Crisp high double pip
			_generate_tone(playback, 660.0, 0.05, 0.3)
			_generate_tone(playback, 880.0, 0.08, 0.4)
		"attack":
			# Deep combat horn / strike
			_generate_tone(playback, 220.0, 0.12, 0.5)
		"build":
			# Ascending chime
			_generate_tone(playback, 440.0, 0.05, 0.3)
			_generate_tone(playback, 554.0, 0.05, 0.3)
			_generate_tone(playback, 659.0, 0.10, 0.4)
		"alert":
			# Minor warning chime
			_generate_tone(playback, 370.0, 0.08, 0.4)
			_generate_tone(playback, 311.0, 0.12, 0.5)

func _get_available_player() -> AudioStreamPlayer:
	for p in audio_players:
		if not p.playing:
			return p
	return audio_players[0]

func _generate_tone(playback: AudioStreamGeneratorPlayback, freq: float, duration: float, volume: float) -> void:
	var sample_rate = 22050.0
	var total_samples = int(sample_rate * duration)
	for i in range(total_samples):
		var t = float(i) / sample_rate
		var sample = sin(TAU * freq * t) * volume * (1.0 - float(i) / float(total_samples))
		playback.push_frame(Vector2(sample, sample))

func _on_notification_sound(_title: String, _body: String, col: Color) -> void:
	if col.r > 0.8 and col.g < 0.5:
		play_sfx("alert")
	elif col.g > 0.8:
		play_sfx("build")
	else:
		play_sfx("order")
