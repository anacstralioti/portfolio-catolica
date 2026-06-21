extends Node

# Motor narrativo central, FSM + clima + spawn aleatório + save/load.
# É o coração do jogo: coordena todos os sistemas da Fase 1.

# ── FSM: 5 estados narrativos ─────────────────────────────────────────────────
# Cada estado corresponde a uma faixa de progresso do mapa (0–6400 px).
# As transições disparam simultaneamente: clima, narrativa e detritos visuais.
enum State {
	INICIO,          # 0–15%   — praia quieta, sol claro
	RECONHECIMENTO,  # 15–40%  — memórias começam a surgir, leve nublado
	LEMBRANCA,       # 40–65%  — lembranças fortes, céu encoberto
	CONFRONTO,       # 65–85%  — pico emocional, chuva leve
	RESOLUCAO        # 85–100% — caminhada final, luz dourada
}

# Textos narrativos centralizados no dicionário
const NARRATIVAS := {
	"intro"          : "Está tudo tão quieto...",
	"reconhecimento" : "Este lugar... parece familiar.",
	"lembranca"      : "Quanto tempo eu fiquei longe?",
	"confronto"      : "Não consigo parar de pensar nela.",
	"resolucao"      : "Tem algo além do horizonte.",
	"checkpoint1"    : "Eu preciso continuar.",
	"checkpoint2"    : "Mais longe do que eu lembrava.",
	"checkpoint3"    : "Quase lá.",
	"item_shovel"    : "A pá dela. Ainda estava aqui.",
	"item_bucket"    : "O baldinho que ela usava pra fazer castelos.",
	"shell"          : "Ela colecionava essas coisas.",
}

const SAVE_PATH_TPL := "user://fase1_save_slot%d.json"

# Zonas de spawn para cada tipo de objeto, pares [x_min, x_max] em pixels.
# O spawn aleatório distribui um objeto por zona, evitando sobreposições.
const CRAB_ZONES    := [[300, 700], [1100, 1600], [1700, 2200], [2800, 3500], [4800, 5400]]
const PUDDLE_ZONES  := [[700, 1100], [1300, 1800], [1900, 2400], [3700, 4200]]
const HOLE_ZONES    := [[350, 550], [1050, 1350], [2900, 3300]]
const MEMORY_ZONES  := [[1100, 1800], [2100, 2900], [3100, 3900], [4200, 5000], [5200, 5900]]

const MAP_W := 6400.0

# Posição X de spawn por checkpoint ao carregar um save, Ichigo aparece aqui
const _CHECKPOINT_X := { 0: 80.0, 1: 700.0, 2: 2200.0, 3: 4500.0 }

# ── Estado em execução ────────────────────────────────────────────────────────
var state       := State.INICIO
var progress    := 0.0   # normalizado 0–1 (posição X / MAP_W)
var shells      := 0
var checkpoints := 0
var _spawn_x    := 80.0  # posição de spawn do jogador (carregada do save)
var _ending     := false # evita emitir phase_complete mais de uma vez
var _rng        := RandomNumberGenerator.new()
var _run_seed   := 0     # seed aleatória salva, garante replay determinístico

# ── Sistema de clima (CanvasLayer sobre o mundo, abaixo da UI) ────────────────
var _weather_canvas: CanvasLayer
var _weather_tint:   ColorRect      # overlay de cor que escurece/colore o mundo
var _weather_rain:   CPUParticles2D # partículas de chuva (ativas apenas no CONFRONTO)
var _weather_tw:     Tween

# ── Música ambiente procedural ────────────────────────────────────────────────
const _AMB_MIX_RATE := 22050.0
var _amb_t        := 0.0   # tempo acumulado (fase dos senos)
var _amb_lfo      := 0.0   # fase do LFO lento, cria shimmer no agudo
var _amb_playback: AudioStreamGeneratorPlayback

signal state_changed(s: int)
signal phase_complete

@onready var music_player:    AudioStreamPlayer = $MusicPlayer
@onready var ambience_player: AudioStreamPlayer = $AmbiencePlayer
@onready var debris_layer:    Node2D            = $World/DebrisLayer
@onready var narrative_ui                       = $UI/NarrativeUI
@onready var hud                                = $UI/HUD


func _ready() -> void:
	add_to_group("game_manager")
	_setup_weather()
	_setup_ambience()
	_load()
	_enter(State.INICIO)
	phase_complete.connect(_on_phase_complete)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.shell_collected.connect(_on_shell)
		player.item_picked_up.connect(_on_item_pickup)
		if _spawn_x != 80.0:
			player.global_position.x = _spawn_x  # reposiciona no checkpoint do save

	call_deferred("_randomize_world")  # deferred: garante que todos os nós estão na árvore


# ── Sistema de clima ──────────────────────────────────────────────────────────

func _setup_weather() -> void:
	# Cria o CanvasLayer de clima em código, layer 8 fica acima do mundo e abaixo da UI
	_weather_canvas = CanvasLayer.new()
	_weather_canvas.layer = 8
	add_child(_weather_canvas)

	_weather_tint = ColorRect.new()
	_weather_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_weather_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_weather_tint.color = Color(0, 0, 0, 0)
	_weather_canvas.add_child(_weather_tint)

	# Partículas de chuva, só emitem no estado CONFRONTO
	_weather_rain = CPUParticles2D.new()
	_weather_rain.emitting              = false
	_weather_rain.amount                = 140
	_weather_rain.lifetime              = 0.7
	_weather_rain.direction             = Vector2(0.12, 1.0).normalized()
	_weather_rain.spread                = 6.0
	_weather_rain.gravity               = Vector2(0, 0)
	_weather_rain.initial_velocity_min  = 340.0
	_weather_rain.initial_velocity_max  = 500.0
	_weather_rain.color                 = Color(0.72, 0.84, 1.0, 0.45)
	_weather_rain.scale_amount_min      = 0.25
	_weather_rain.scale_amount_max      = 0.55
	_weather_rain.emission_shape        = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_weather_rain.emission_rect_extents = Vector2(400, 1)
	_weather_rain.position              = Vector2(320, -10)
	_weather_canvas.add_child(_weather_rain)


func _apply_weather(s: State) -> void:
	if not _weather_tint: return
	if _weather_tw: _weather_tw.kill()
	_weather_tw = create_tween().set_parallel(true)
	# Cada estado tem um tint distinto, a transição é gradual (não brusca)
	match s:
		State.INICIO:
			_weather_tw.tween_property(_weather_tint, "color", Color(1, 1, 0.88, 0.0),  2.5)
			_weather_rain.emitting = false
		State.RECONHECIMENTO:
			_weather_tw.tween_property(_weather_tint, "color", Color(0.84, 0.88, 0.98, 0.06), 3.0)
		State.LEMBRANCA:
			_weather_tw.tween_property(_weather_tint, "color", Color(0.65, 0.70, 0.88, 0.18), 4.0)
		State.CONFRONTO:
			_weather_tw.tween_property(_weather_tint, "color", Color(0.42, 0.48, 0.72, 0.30), 3.5)
			_weather_rain.emitting = true
		State.RESOLUCAO:
			_weather_tw.tween_property(_weather_tint, "color", Color(1, 0.84, 0.52, 0.14), 5.0)
			_weather_rain.emitting = false


# ── Música ambiente procedural ────────────────────────────────────────────────

func _setup_ambience() -> void:
	if not ambience_player: return
	# AudioStreamGenerator: buffer pequeno (0.25s) para latência mínima
	var gen           := AudioStreamGenerator.new()
	gen.mix_rate      = _AMB_MIX_RATE
	gen.buffer_length = 0.25
	ambience_player.stream    = gen
	ambience_player.volume_db = -18.0
	ambience_player.play()
	_amb_playback = ambience_player.get_stream_playback()

	# Ondas do mar em camada separada, toca em loop durante toda a fase
	var ocean := AudioStreamPlayer.new()
	ocean.stream    = ProceduralSFX.ocean_loop()
	ocean.volume_db = -12.0
	add_child(ocean)
	ocean.play()


func _fill_ambience(delta: float) -> void:
	if not _amb_playback: return

	# LFO lento (0.07 Hz), modula o tom mais agudo criando shimmer sutil
	_amb_lfo = fmod(_amb_lfo + delta * 0.07 * TAU, TAU)
	var shimmer := 0.5 + 0.5 * sin(_amb_lfo)

	var frames := _amb_playback.get_frames_available()
	var dt     := 1.0 / _AMB_MIX_RATE

	for _i in frames:
		var s := 0.0
		# Drone em Lá menor: três harmônicos + shimmer no agudo
		s += sin(TAU * 82.4  * _amb_t) * 0.10  # Mi2, baixo profundo
		s += sin(TAU * 110.0 * _amb_t) * 0.07  # Lá2, nota base
		s += sin(TAU * 164.8 * _amb_t) * 0.05  # Mi3, quinta justa
		s += sin(TAU * 220.0 * _amb_t) * 0.03 * shimmer  # Lá3, shimmer
		_amb_playback.push_frame(Vector2(s, s))
		_amb_t += dt


# ── FSM ───────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	# Verifica limiares de progresso para transição de estado
	match state:
		State.INICIO:
			if progress >= 0.15: _enter(State.RECONHECIMENTO)
		State.RECONHECIMENTO:
			if progress >= 0.40: _enter(State.LEMBRANCA)
		State.LEMBRANCA:
			if progress >= 0.65: _enter(State.CONFRONTO)
		State.CONFRONTO:
			if progress >= 0.85: _enter(State.RESOLUCAO)
		State.RESOLUCAO:
			if progress >= 1.0 and not _ending:
				_ending = true
				_save()
				emit_signal("phase_complete")
	_fill_ambience(delta)


func _enter(s: State) -> void:
	state = s
	emit_signal("state_changed", s)
	_apply_weather(s)  # clima muda gradualmente
	match s:
		State.INICIO:
			_show_narrative("intro")
		State.RECONHECIMENTO:
			_show_narrative("reconhecimento")
		State.LEMBRANCA:
			_show_narrative("lembranca")
			_fade_in_debris(0.35)  # detritos começam a aparecer no mundo
		State.CONFRONTO:
			_show_narrative("confronto")
			_fade_in_debris(1.0)   # detritos totalmente visíveis
		State.RESOLUCAO:
			_show_narrative("resolucao")


func _fade_in_debris(target_alpha: float) -> void:
	if debris_layer:
		var tw := create_tween()
		tw.tween_property(debris_layer, "modulate:a", target_alpha, 3.0)


# ── Spawn aleatório determinístico ────────────────────────────────────────────

func _randomize_world() -> void:
	# Usa a seed salva para garantir que ao continuar um save
	# os objetos apareçam nas mesmas posições da sessão anterior
	_rng.seed = _run_seed
	_randomize_group_positions("crab",        CRAB_ZONES)
	_randomize_group_positions("puddle",      PUDDLE_ZONES)
	_randomize_group_positions("sandhole",    HOLE_ZONES)
	_randomize_group_positions("memory_item", MEMORY_ZONES)


const _CHECKPOINT_CLEARANCE := 90.0  # objetos não podem spawnar a menos de 90px de um checkpoint

func _near_checkpoint(x: float) -> bool:
	for cp_x in _CHECKPOINT_X.values():
		if abs(x - cp_x) < _CHECKPOINT_CLEARANCE:
			return true
	return false


func _randomize_group_positions(group: String, zones: Array) -> void:
	var nodes := get_tree().get_nodes_in_group(group)
	if nodes.is_empty(): return
	var count := mini(nodes.size(), zones.size())

	# Embaralha as zonas (Fisher-Yates) para distribuição uniforme
	var zone_indices: Array[int] = []
	for i in zones.size():
		zone_indices.append(i)
	for i in range(zone_indices.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp: int = zone_indices[i]
		zone_indices[i] = zone_indices[j]
		zone_indices[j] = tmp

	for i in count:
		var zone: Array = zones[zone_indices[i]]
		var new_x: float = _rng.randf_range(float(zone[0]), float(zone[1]))
		# Até 12 tentativas para evitar sobreposição com checkpoints
		var tries := 0
		while _near_checkpoint(new_x) and tries < 12:
			new_x = _rng.randf_range(float(zone[0]), float(zone[1]))
			tries += 1
		nodes[i].global_position.x = new_x


# ── Progresso e eventos ───────────────────────────────────────────────────────

func update_progress(x: float, map_w: float) -> void:
	progress = clamp(x / map_w, 0.0, 1.0)
	if hud and hud.has_method("update_progress"):
		hud.update_progress(progress)


func register_checkpoint(id: int) -> void:
	if id > checkpoints:
		checkpoints = id
		_spawn_x = _CHECKPOINT_X.get(id, _spawn_x)
		_save()  # salva automaticamente ao atingir um checkpoint
	var key := "checkpoint%d" % id
	if NARRATIVAS.has(key):
		_show_narrative(key)


func _on_shell(total: int) -> void:
	shells = total
	if hud and hud.has_method("add_to_inventory"):
		hud.add_to_inventory("shell")
	# Dispara fala narrativa a cada 3 e 6 conchas coletadas
	if total == 3 or total == 6:
		_show_narrative("shell")


func _on_item_pickup(item_name: String) -> void:
	if hud and hud.has_method("add_to_inventory"):
		hud.add_to_inventory(item_name)
	var key := "item_%s" % item_name
	if NARRATIVAS.has(key):
		_show_narrative(key)
	_save()  # salva ao coletar item importante


func _on_phase_complete() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("disable"):
		player.disable()  # Ichigo anda automaticamente para a direita
	_show_narrative("resolucao")
	await get_tree().create_timer(2.8).timeout
	GameGlobal.next_phase_number = 2
	GameGlobal.next_phase_name   = "Ruínas do Oceano"
	get_tree().change_scene_to_file("res://scenes/tsunami_cutscene.tscn")


func show_custom_narrative(text: String) -> void:
	if narrative_ui:
		narrative_ui.show_text(text)


func _show_narrative(key: String) -> void:
	if narrative_ui and NARRATIVAS.has(key):
		narrative_ui.show_text(NARRATIVAS[key])


# ── Save / Load ───────────────────────────────────────────────────────────────

func _get_save_path() -> String:
	return SAVE_PATH_TPL % GameGlobal.current_save_slot


func save_game() -> void:
	_save()


func _save() -> void:
	var inv_data := {}
	if hud and hud.has_method("get_inventory_data"):
		inv_data = hud.get_inventory_data()
	var f := FileAccess.open(_get_save_path(), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"shells"     : shells,
			"checkpoints": checkpoints,
			"progress"   : progress,
			"state"      : state,
			"spawn_x"    : _spawn_x,
			"run_seed"   : _run_seed,  # seed salva garante mesmas posições de objetos
			"inventory"  : inv_data,
		}))
		f.close()


func _load() -> void:
	_run_seed = randi()  # nova seed por padrão (novo jogo)
	var path := _get_save_path()
	if not FileAccess.file_exists(path): return
	var f := FileAccess.open(path, FileAccess.READ)
	if not f: return
	var j := JSON.new()
	if j.parse(f.get_as_text()) != OK:
		f.close()
		return
	var d: Dictionary = j.get_data()
	shells      = d.get("shells", 0)
	checkpoints = d.get("checkpoints", 0)
	progress    = d.get("progress", 0.0)
	_spawn_x    = d.get("spawn_x", _CHECKPOINT_X.get(checkpoints, 80.0))
	_run_seed   = d.get("run_seed", _run_seed)
	f.close()
	if d.has("inventory") and hud and hud.has_method("restore_inventory"):
		hud.restore_inventory(d["inventory"])
