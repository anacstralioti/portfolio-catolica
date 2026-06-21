extends Sprite2D

# Rádio com estática procedural, gera ruído via AudioStreamGenerator em runtime.
# Volume sobe conforme o jogador se aproxima e cai ao se afastar (fade por distância).

const HEAR_RANGE  := 180.0   # px, distância máxima para ouvir o rádio
const MIX_RATE    := 22050   # Hz, taxa de amostragem do gerador
const MAX_VOL_DB  := -5.0    # volume máximo em dB (quando o jogador está em cima)
const FADE_SPEED  := 2.8     # velocidade de fade de volume (linear por segundo)

var _player:   AudioStreamPlayer2D
var _playback: AudioStreamGeneratorPlayback
var _vol        := 0.0   # volume atual (linear 0–1)
var _target_vol := 0.0   # volume alvo, interpolado suavemente por move_toward
var _flicker    := 1.0   # amplitude do flicker de sinal (0.25–1.0)
var _flicker_t  := 0.0   # temporizador do flicker (troca a cada ~60ms)
var _prev_s     := 0.0   # sample anterior, suaviza o espectro (pink noise)


func _ready() -> void:
	_player              = AudioStreamPlayer2D.new()
	_player.max_distance = HEAR_RANGE * 2.5
	_player.volume_db    = -80.0  # começa inaudível
	add_child(_player)

	# Buffer curto (0.12s) para latência mínima no preenchimento do gerador
	var gen           := AudioStreamGenerator.new()
	gen.mix_rate      = MIX_RATE
	gen.buffer_length = 0.12
	_player.stream    = gen
	_player.play()
	_playback = _player.get_stream_playback()


func _process(delta: float) -> void:
	_update_proximity()
	# Suaviza o volume para evitar cortes abruptos ao entrar/sair do alcance
	_vol = move_toward(_vol, _target_vol, FADE_SPEED * delta)
	_player.volume_db = linear_to_db(maxf(_vol, 0.0001)) + MAX_VOL_DB
	_fill_buffer(delta)


func _update_proximity() -> void:
	var ichigo := get_tree().get_first_node_in_group("player")
	if not ichigo:
		_target_vol = 0.0
		return
	var dist    := global_position.distance_to(ichigo.global_position)
	# Volume cai linearmente com a distância (1.0 = em cima, 0.0 = fora do alcance)
	_target_vol  = clampf(1.0 - dist / HEAR_RANGE, 0.0, 1.0)


func _fill_buffer(delta: float) -> void:
	if not _playback:
		return

	# Flicker do sinal: amplitude oscila a cada ~60ms simulando interferência de rádio
	_flicker_t += delta
	if _flicker_t >= 0.06:
		_flicker_t = 0.0
		_flicker   = lerpf(_flicker, randf_range(0.25, 1.0), 0.4)

	var frames := _playback.get_frames_available()
	for _i in frames:
		# Pink noise: white noise suavizado com IIR simples (65% novo, 35% anterior)
		# Pink noise soa mais natural que white noise puro para estática de rádio
		var white := randf_range(-1.0, 1.0)
		var s     := (white * 0.65 + _prev_s * 0.35) * _flicker
		_prev_s   = s
		_playback.push_frame(Vector2(s, s))
