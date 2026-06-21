extends Node2D

# Cutscene do tsunami
# Toda a cena é desenhada via _draw().
# A sequência usa três Tweens em paralelo para a onda, a palmeira e a placa.

# ── Paleta de cores (pixel art tempestuosa) ───────────────────────────────────
const C_SKY_TOP      := Color(0.18, 0.18, 0.24)   # céu, cinza escuro no topo
const C_SKY_MID      := Color(0.26, 0.27, 0.34)
const C_SKY_HORIZON  := Color(0.36, 0.37, 0.44)   # horizonte, mais claro
const C_CLOUD_DARK   := Color(0.30, 0.31, 0.38)
const C_CLOUD_LIGHT  := Color(0.50, 0.52, 0.60)   # borda iluminada das nuvens
const C_OCEAN        := Color(0.04, 0.18, 0.36)   # oceano profundo
const C_OCEAN2       := Color(0.08, 0.30, 0.52)   # reflexo animado das ondas
const C_WAVE_SHADOW  := Color(0.02, 0.10, 0.26)   # sombra nas costas da onda
const C_WAVE_A       := Color(0.05, 0.20, 0.48)   # corpo traseiro da onda
const C_WAVE_B       := Color(0.08, 0.36, 0.66)   # corpo médio
const C_WAVE_C       := Color(0.12, 0.58, 0.82)   # face frontal, azul-ciano
const C_WAVE_D       := Color(0.24, 0.80, 0.94)   # frente brilhante, ciano vivo
const C_FOAM         := Color(0.82, 0.96, 0.98)   # espuma
const C_WHITE        := Color(1.00, 1.00, 1.00)
const C_SAND_D       := Color(0.56, 0.42, 0.18)   # areia escura
const C_SAND_M       := Color(0.72, 0.58, 0.30)   # areia média
const C_SAND_L       := Color(0.84, 0.72, 0.44)   # areia clara (borda da praia)
const C_FLOOD        := Color(0.04, 0.16, 0.28)   # água da inundação
const C_RAIN         := Color(0.55, 0.72, 0.88, 0.50)
const C_TRUNK_L      := Color(0.52, 0.34, 0.12)
const C_TRUNK_D      := Color(0.36, 0.22, 0.06)
const C_LEAF         := Color(0.22, 0.52, 0.14)
const C_LEAF_D       := Color(0.14, 0.36, 0.08)

# ── Estado da animação ────────────────────────────────────────────────────────
var wave_x    := 380.0   # posição X da onda (px), vai de 380 (direita) até -90 (batida)
var wave_h    := 8.0     # altura da onda (px), vai de 8 até 100
var phase     := 0       # 0=onda chegando, 1=impacto, 2=enchente, 3=fade
var flood_lvl := 0.0    # nível da enchente (0=seco, 1=totalmente alagado)
var time      := 0.0    # tempo acumulado para animações periódicas (chuva, ondas, fogo)
var lightning := 0.0    # intensidade do flash do raio (decai exponencialmente)
var tree_lean  := 0.0   # inclinação da palmeira (0=vertical, 1=78° = caída)
var sign_drift := 0.0   # quanto a placa foi arrastada pela enchente (0→1)
var _thunder_cooldown := 0.0  # impede trovões muito seguidos (mínimo 2.8s)

var _sfx_storm:   AudioStreamPlayer
var _sfx_thunder: AudioStreamPlayer

@onready var screen_fade: ColorRect = $FadeLayer/ScreenFade


func _ready() -> void:
	# Tempestade começa imediatamente e fica em loop até a transição
	_sfx_storm = AudioStreamPlayer.new()
	_sfx_storm.stream    = ProceduralSFX.storm_loop()
	_sfx_storm.volume_db = -8.0
	add_child(_sfx_storm)
	_sfx_storm.play()

	_sfx_thunder = AudioStreamPlayer.new()
	_sfx_thunder.volume_db = -2.0
	add_child(_sfx_thunder)

	screen_fade.modulate.a = 0.0
	_run_sequence()


func _run_sequence() -> void:
	# Tween 1: progressão principal da onda e fade final
	# Segmento A: onda viaja da direita até o impacto (4.5s, aceleração quadrática)
	# Segmento B: onda quebra e passa pela tela (1.2s, desaceleração exponencial)
	# Segmento C: enchente sobe (2.5s), tela escurece (2.5s) e cena muda
	var tw := create_tween()
	tw.tween_method(_set_wave, Vector2(380.0, 8.0), Vector2(85.0, 100.0), 4.5
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void: phase = 1)
	tw.tween_method(_set_wave, Vector2(85.0, 100.0), Vector2(-90.0, 20.0), 1.2
		).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: phase = 2; _shake())
	tw.tween_property(self, "flood_lvl", 1.0, 2.5)
	tw.tween_callback(func() -> void: phase = 3)
	tw.tween_property(screen_fade, "modulate:a", 1.0, 2.5)
	tw.tween_interval(0.4)
	tw.tween_callback(_transition)

	# Tween 2: palmeira começa a cair quando a onda bate (t=4.5s)
	var tw_tree := create_tween()
	tw_tree.tween_interval(4.5)
	tw_tree.tween_property(self, "tree_lean", 1.0, 3.2
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Tween 3: placa é arrastada 0.5s após o início da enchente (t=5.7s+0.5s=6.2s)
	var tw_sign := create_tween()
	tw_sign.tween_interval(6.2)
	tw_sign.tween_property(self, "sign_drift", 1.0, 2.0
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _set_wave(v: Vector2) -> void:
	# Callback do tween_method, atualiza posição e altura da onda simultaneamente
	wave_x = v.x
	wave_h  = v.y


func _shake() -> void:
	# Tremor de câmera ao impacto da onda, 14 micro-deslocamentos em 0.7s
	var tw := create_tween()
	for i in range(14):
		tw.tween_property(self, "position", Vector2(randf_range(-3.0, 3.0), randf_range(-2.0, 2.0)), 0.05)
	tw.tween_property(self, "position", Vector2.ZERO, 0.12)


func _transition() -> void:
	GameGlobal.next_phase_number = 2
	GameGlobal.next_phase_name   = "Ruínas do Oceano"
	get_tree().change_scene_to_file("res://scenes/phase_intro.tscn")


func _process(delta: float) -> void:
	time += delta
	_thunder_cooldown = maxf(0.0, _thunder_cooldown - delta)

	# Raios aleatórios: probabilidade 0.4% por frame, para antes do fade (phase < 3)
	var was_dark := lightning < 0.05
	lightning = maxf(0.0, lightning - delta * 5.0)  # decaimento do flash
	if randf() < 0.004 and phase < 3:
		lightning = randf_range(0.5, 0.9)
		if was_dark and _thunder_cooldown <= 0.0:
			_thunder_cooldown = 2.8  # próximo trovão em no mínimo 2.8s
			_sfx_thunder.pitch_scale = randf_range(0.85, 1.15)
			_sfx_thunder.stream = ProceduralSFX.thunder()
			_sfx_thunder.play()
	queue_redraw()  # força redesenho a cada frame


# ── Função de desenho principal ───────────────────────────────────────────────

func _draw() -> void:
	# Canvas: 320×180 px (resolução nativa do jogo)
	var W       := 320.0
	var H       := 180.0
	var HORIZON := 108.0  # onde o oceano começa (linha do horizonte)
	var GROUND  := 140.0  # onde a praia começa (solo)

	_draw_sky(W, HORIZON)
	_draw_ocean(W, HORIZON, GROUND)
	_draw_beach(W, GROUND, H)
	if phase <= 1:
		_draw_wave(W, GROUND)  # onda desaparece após o impacto (phase 2+)
	_draw_flood(W, GROUND, H)
	_draw_palm_tree(GROUND)
	_draw_fire_sign(GROUND)
	_draw_rain(W, H)

	# Overlay do relâmpago, retângulo branco semitransparente sobre tudo
	if lightning > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(0.85, 0.90, 1.0, lightning * 0.28))


# ── Céu com nuvens tempestuosas ───────────────────────────────────────────────

func _draw_sky(W: float, horizon: float) -> void:
	# 4 faixas de gradiente manual (pixel art não tem gradiente real)
	draw_rect(Rect2(0, 0,              W, horizon * 0.38), C_SKY_TOP)
	draw_rect(Rect2(0, horizon * 0.38, W, horizon * 0.28), C_SKY_MID)
	draw_rect(Rect2(0, horizon * 0.66, W, horizon * 0.20), Color(0.30, 0.31, 0.38))
	draw_rect(Rect2(0, horizon * 0.86, W, horizon * 0.14), C_SKY_HORIZON)

	# 9 nuvens em 3 camadas (alta, média, baixa/névoa)
	# formato: [x, y, w, h, usa_highlight]
	var clouds := [
		[-4,   0,  124, 32,  true],
		[118,  2,  108, 30,  true],
		[210, -2,  116, 34,  true],
		[ 20, 28,   92, 22,  true],
		[142, 26,   86, 24,  true],
		[254, 24,   72, 20,  true],
		[ 44, 50,   68, 16,  false],
		[174, 48,   80, 18,  false],
		[268, 46,   58, 14,  false],
	]
	for c in clouds:
		draw_rect(Rect2(c[0],     c[1],     c[2],     c[3]),     C_CLOUD_DARK)
		if c[4]:
			# Highlight na borda superior e sombra escura no canto direito
			draw_rect(Rect2(c[0]+5,   c[1]-5,   c[2]-10,  6),       C_CLOUD_LIGHT)
			draw_rect(Rect2(c[0]+c[2]-18, c[1], 18, int(c[3]*0.5)), C_CLOUD_DARK)

	# Relâmpago em zigue-zague, só visível quando lightning > 0.35
	if lightning > 0.35:
		draw_rect(Rect2(138, 44, 3, 16), C_WHITE)
		draw_rect(Rect2(144, 58, 3, 13), C_WHITE)
		draw_rect(Rect2(136, 69, 4, 11), C_WHITE)


# ── Oceano com reflexos animados ──────────────────────────────────────────────

func _draw_ocean(W: float, horizon: float, ground: float) -> void:
	draw_rect(Rect2(0, horizon, W, ground - horizon), C_OCEAN)
	# 5 faixas de reflexo animadas, velocidades diferentes criam parallax
	for i in range(5):
		var off := fmod(time * (16.0 + i * 5.0) + i * 22.0, W + 24.0)
		var ry  := horizon + 5.0 + i * 6.0
		draw_rect(Rect2(W - off,      ry, 20, 2), C_OCEAN2)
		draw_rect(Rect2(W - off - 18, ry + 1, 9, 1), C_OCEAN2)


# ── Praia com textura de areia ────────────────────────────────────────────────

func _draw_beach(W: float, ground: float, H: float) -> void:
	var bh := H - ground
	draw_rect(Rect2(0, ground,     W, bh), C_SAND_M)
	draw_rect(Rect2(0, ground,     W,  5), C_SAND_L)   # linha de areia molhada
	draw_rect(Rect2(0, ground + 5, W,  3), Color(0.68, 0.54, 0.26))
	# Detalhe: pedrinhas e irregularidades espalhadas por hash determinístico
	for ix in range(0, int(W), 14):
		for iy in range(2, int(bh), 10):
			if (ix * 7 + iy * 3) % 17 < 6:
				draw_rect(Rect2(ix + 3, ground + iy + 1, 3, 2), C_SAND_D)


# ── Palmeira com rotação pivotada na base ─────────────────────────────────────

func _draw_palm_tree(ground: float) -> void:
	# draw_set_transform define o pivot em (260, ground) e aplica rotação progressiva.
	# tree_lean vai 0→1, ângulo vai 0→78° (quase horizontal quando cai).
	draw_set_transform(Vector2(260.0, ground), tree_lean * deg_to_rad(78.0))
	_draw_palm_body()
	draw_set_transform(Vector2.ZERO, 0.0)  # restaura transform antes de desenhar outros elementos


func _draw_palm_body() -> void:
	# Coordenadas relativas ao pivot (base da palmeira = 0,0).
	# O tronco tem 16 segmentos com leve inclinação crescente (lean).
	for i in range(16):
		var lean := i * 0.4   # cada segmento inclina 0.4px para esquerda
		var tx   := -lean
		var ty   := -(i * 4 + 4)
		draw_rect(Rect2(tx,     ty, 2, 4), C_TRUNK_D)
		draw_rect(Rect2(tx + 2, ty, 3, 4), C_TRUNK_L)
		if i % 3 == 0:
			draw_rect(Rect2(tx, ty + 1, 1, 2), Color(0.28, 0.16, 0.04))  # nó do tronco

	# Copa: 5 grupos de folhas saindo em direções diferentes
	var tx := -16.0 * 0.4  # topo do tronco
	var ty := -64.0

	for i in range(7):   # folhas para cima-frente
		draw_rect(Rect2(tx + 1 + i * 0.3, ty - 4 - i * 4, 4, 3), C_LEAF)
		if i > 3:
			draw_rect(Rect2(tx - 1 + i * 0.3, ty - 4 - i * 4 + 1, 2, 2), C_LEAF_D)

	for i in range(11):  # folhas para direita
		draw_rect(Rect2(tx + 4 + i * 4, ty + i - 2, 5, 3), C_LEAF)
		draw_rect(Rect2(tx + 4 + i * 4, ty + i + 1, 3, 1), C_LEAF_D)

	for i in range(11):  # folhas para esquerda
		draw_rect(Rect2(tx - i * 4, ty + i - 2, 5, 3), C_LEAF)
		draw_rect(Rect2(tx - i * 4 + 1, ty + i + 1, 3, 1), C_LEAF_D)

	for i in range(9):   # folhas para cima-direita diagonal
		draw_rect(Rect2(tx + 3 + i * 3, ty - 2 - i * 3, 4, 3), C_LEAF)

	for i in range(9):   # folhas para cima-esquerda diagonal
		draw_rect(Rect2(tx - 1 - i * 3, ty - 2 - i * 3, 4, 3), C_LEAF)

	for i in range(8):   # sombras das folhas (direita)
		draw_rect(Rect2(tx + 5 + i * 3, ty + 4 + i * 2, 4, 3), C_LEAF_D)

	for i in range(8):   # sombras das folhas (esquerda)
		draw_rect(Rect2(tx - 2 - i * 3, ty + 4 + i * 2, 4, 3), C_LEAF_D)


# ── Placa com fogo arrastada pela enchente ────────────────────────────────────

func _draw_fire_sign(ground: float) -> void:
	# Pivot na base do poste. sign_drift 0→1:
	# - X: desloca 130px para a direita (arrastada pela corrente)
	# - Y: sobe 8px (flutua)
	# - ângulo: 0→90° (cai horizontalmente)
	var pivot_x  := 236.0 + sign_drift * 130.0
	var pivot_y  := ground - sign_drift * 8.0
	var angle    := sign_drift * deg_to_rad(90.0)

	draw_set_transform(Vector2(pivot_x, pivot_y), angle)

	draw_rect(Rect2(0,  -22, 2, 22), Color(0.18, 0.10, 0.04))  # poste

	# Placa de madeira
	draw_rect(Rect2(-4, -27, 12, 7), Color(0.55, 0.26, 0.08))
	draw_rect(Rect2(-3, -28, 10, 1), Color(0.44, 0.20, 0.06))
	draw_rect(Rect2(-4, -27, 12, 1), Color(0.66, 0.34, 0.12))

	# Fogo, apaga progressivamente enquanto sign_drift vai de 0→0.5
	if sign_drift < 0.5:
		var fade     := 1.0 - sign_drift * 2.0
		var flicker  := sin(time * 11.0) * 0.5 + 0.5    # LFO rápido (11 Hz)
		var flicker2 := sin(time * 17.0 + 1.2) * 0.5 + 0.5  # LFO mais rápido e desfasado
		draw_rect(Rect2(-2, -32, 8, 6), Color(0.88, 0.42, 0.04, fade))
		draw_rect(Rect2(-1, -35, 6, 4), Color(0.96, 0.76, 0.08, fade))
		draw_rect(Rect2( 0, -37, 4, 3), Color(0.98, 0.90, 0.20, fade))
		if flicker > 0.35:
			draw_rect(Rect2( 1, -39, 2, 3), Color(0.90, 0.52, 0.04, fade))
		if flicker2 > 0.60:
			draw_rect(Rect2( 0, -41, 2, 2), Color(0.80, 0.18, 0.02, fade))
		if flicker > 0.70:
			draw_rect(Rect2(-2, -38, 1, 2), Color(0.98, 0.82, 0.14, fade * 0.7))
			draw_rect(Rect2( 5, -37, 1, 2), Color(0.98, 0.62, 0.04, fade * 0.7))

	draw_set_transform(Vector2.ZERO, 0.0)


# ── Onda principal em 5 camadas de polígonos ─────────────────────────────────

func _draw_wave(W: float, ground: float) -> void:
	if wave_x > W + 12:
		return  # onda ainda fora do canvas (direita)

	var wh  := wave_h
	var wx  := wave_x
	var top := ground - wh

	if wh < 2.0:
		return

	# Rastro de água, faixa horizontal atrás da onda
	if wx < W:
		var trail := clampf(wx + wh * 0.55, 0.0, W)
		draw_rect(Rect2(trail, ground - 12, W - trail, 12), C_WAVE_A)
		draw_rect(Rect2(trail, ground - 5,  W - trail,  5), C_WAVE_B)

	# 5 polígonos sobrepostos criam a forma tridimensional da onda:
	# cada camada é ligeiramente menor e mais brilhante que a anterior.

	var _p0 := PackedVector2Array([  # massa sombria (costas)
		Vector2(wx + wh * 0.88, ground), Vector2(wx + wh * 0.68, ground - wh * 0.18),
		Vector2(wx + wh * 0.42, ground - wh * 0.52), Vector2(wx + wh * 0.16, ground - wh * 0.95),
		Vector2(wx,             ground - wh * 1.04), Vector2(wx - wh * 0.10, ground - wh * 0.97),
		Vector2(wx - wh * 0.20, ground - wh * 0.62), Vector2(wx - wh * 0.30, ground - wh * 0.10),
		Vector2(wx - wh * 0.38, ground),
	])
	draw_polygon(_p0, PackedColorArray([C_WAVE_SHADOW]))

	var _p1 := PackedVector2Array([  # corpo escuro
		Vector2(wx + wh * 0.76, ground), Vector2(wx + wh * 0.58, ground - wh * 0.18),
		Vector2(wx + wh * 0.34, ground - wh * 0.52), Vector2(wx + wh * 0.10, ground - wh * 0.93),
		Vector2(wx - wh * 0.02, ground - wh * 1.01), Vector2(wx - wh * 0.12, ground - wh * 0.92),
		Vector2(wx - wh * 0.22, ground - wh * 0.58), Vector2(wx - wh * 0.30, ground - wh * 0.08),
		Vector2(wx - wh * 0.26, ground),
	])
	draw_polygon(_p1, PackedColorArray([C_WAVE_A]))

	var _p2 := PackedVector2Array([  # corpo médio
		Vector2(wx + wh * 0.58, ground), Vector2(wx + wh * 0.44, ground - wh * 0.18),
		Vector2(wx + wh * 0.22, ground - wh * 0.53), Vector2(wx + wh * 0.01, ground - wh * 0.91),
		Vector2(wx - wh * 0.10, ground - wh * 0.98), Vector2(wx - wh * 0.16, ground - wh * 0.84),
		Vector2(wx - wh * 0.24, ground - wh * 0.50), Vector2(wx - wh * 0.26, ground - wh * 0.06),
		Vector2(wx - wh * 0.20, ground),
	])
	draw_polygon(_p2, PackedColorArray([C_WAVE_B]))

	var _p3 := PackedVector2Array([  # face frontal (azul-ciano)
		Vector2(wx + wh * 0.38, ground), Vector2(wx + wh * 0.26, ground - wh * 0.19),
		Vector2(wx + wh * 0.06, ground - wh * 0.55), Vector2(wx - wh * 0.06, ground - wh * 0.92),
		Vector2(wx - wh * 0.14, ground - wh * 0.92), Vector2(wx - wh * 0.20, ground - wh * 0.72),
		Vector2(wx - wh * 0.24, ground - wh * 0.40), Vector2(wx - wh * 0.22, ground),
	])
	draw_polygon(_p3, PackedColorArray([C_WAVE_C]))

	var _p4 := PackedVector2Array([  # borda luminosa (ciano puro)
		Vector2(wx + wh * 0.20, ground), Vector2(wx + wh * 0.10, ground - wh * 0.20),
		Vector2(wx - wh * 0.04, ground - wh * 0.58), Vector2(wx - wh * 0.10, ground - wh * 0.90),
		Vector2(wx - wh * 0.16, ground - wh * 0.88), Vector2(wx - wh * 0.20, ground - wh * 0.68),
		Vector2(wx - wh * 0.22, ground - wh * 0.35), Vector2(wx - wh * 0.18, ground),
	])
	draw_polygon(_p4, PackedColorArray([C_WAVE_D]))

	# Interior do barril (tubo da onda enrolada), visível apenas quando wh > 18px
	if wh > 18.0:
		var bf := clampf((wh - 18.0) / 82.0, 0.0, 1.0)
		var _bp := PackedVector2Array([
			Vector2(wx - wh * 0.04,  ground - wh * 0.16),
			Vector2(wx - wh * 0.10,  ground - wh * (0.48 + 0.14 * bf)),
			Vector2(wx - wh * 0.08,  ground - wh * (0.80 + 0.10 * bf)),
			Vector2(wx + wh * 0.02,  ground - wh * (0.82 + 0.10 * bf)),
			Vector2(wx + wh * 0.16,  ground - wh * (0.64 + 0.10 * bf)),
			Vector2(wx + wh * 0.14,  ground - wh * 0.22),
			Vector2(wx + wh * 0.04,  ground - wh * 0.10),
		])
		draw_polygon(_bp, PackedColorArray([C_OCEAN]))
		if wh > 40.0:
			draw_rect(Rect2(wx - wh*0.09, ground - wh * 0.80, wh * 0.10, 2),
				Color(C_WAVE_D.r, C_WAVE_D.g, C_WAVE_D.b, 0.55))

	# Listras diagonais de água na face da onda (textura)
	var nst := maxi(3, int(wh * 0.20))
	for i in nst:
		var t    := float(i + 1) / float(nst + 1)
		var sy   := ground - wh * (0.08 + 0.80 * t)
		var sx_r := wx + wh * (0.65 - 0.50 * t)
		var sx_l := wx + wh * (0.28 - 0.35 * t)
		var sw   := maxf(sx_r - sx_l, 0.0)
		if sw > 0.5:
			draw_rect(Rect2(sx_l, sy, sw, 1),
				Color(C_WAVE_D.r, C_WAVE_D.g, C_WAVE_D.b, 0.22))

	# Crista e espuma no topo
	var cw := clampf(wh / 70.0, 0.0, 1.0)
	draw_rect(Rect2(wx - wh*0.08,  top,      wh * 0.28 * cw, 4), C_WAVE_D)
	draw_rect(Rect2(wx - wh*0.14,  top - 3,  wh * 0.20 * cw, 3), C_FOAM)
	draw_rect(Rect2(wx - wh*0.18,  top - 6,  wh * 0.14 * cw, 3), C_WHITE)
	if wh > 30.0:
		draw_rect(Rect2(wx - wh*0.22, top - 9,  wh * 0.10 * cw, 2), C_WHITE)
		draw_rect(Rect2(wx - wh*0.08, top - 2,  wh * 0.08 * cw, 2), C_FOAM)

	# Espuma na base da onda
	var bx := wx - wh * 0.38
	var bw := wh * 0.50
	draw_rect(Rect2(bx,     ground - 10, bw,       10), C_FOAM)
	draw_rect(Rect2(bx + 2, ground - 4,  bw * 0.6,  4), C_WHITE)

	# Spray de partículas no impacto (apenas no phase 1, quando a onda está grande)
	if phase == 1 and wh > 12.0:
		for i in range(14):
			var t_s   := fmod(time * 4.5 + i * 0.12, 1.0)
			var angle := -PI * 0.85 + i * (PI * 0.65 / 13.0)
			var dx    := wx + cos(angle) * wh * t_s
			var dy    := top  + sin(angle) * wh * t_s
			draw_rect(Rect2(dx, dy, 2, 2), C_WHITE)
			if t_s < 0.5:
				draw_rect(Rect2(dx + 1, dy - 2, 2, 2), C_FOAM)


# ── Enchente que sobe após o impacto ─────────────────────────────────────────

func _draw_flood(W: float, ground: float, H: float) -> void:
	if flood_lvl <= 0.0:
		return
	# Sobe até 62% da área da praia; opacidade máxima de 88%
	var fh    := flood_lvl * (H - ground) * 0.62
	var fy    := H - fh
	var alpha := minf(flood_lvl * 1.5, 0.88)
	draw_rect(Rect2(0, fy, W, fh), Color(C_FLOOD.r, C_FLOOD.g, C_FLOOD.b, alpha))
	# Espuma animada na superfície da enchente
	if flood_lvl > 0.12:
		for ix in range(0, int(W), 22):
			var ox := fmod(time * 22.0 + ix * 4.0, W + 22.0) - 11.0
			draw_rect(Rect2(ox,     fy, 11, 2), Color(C_FOAM.r,  C_FOAM.g,  C_FOAM.b,  0.70))
			draw_rect(Rect2(ox + 4, fy,  5, 1), Color(C_WHITE.r, C_WHITE.g, C_WHITE.b, 0.50))


# ── Chuva (para no phase 3 quando a tela está escurecendo) ───────────────────

func _draw_rain(W: float, H: float) -> void:
	if phase >= 3:
		return
	# 44 gotas com velocidades e posições diferentes (variação por índice i)
	for i in range(44):
		var rx := fmod(i * 7.8  + time * 28.0, W)
		var ry := fmod(i * 4.4  + time * (88.0 + i * 0.70), H)
		draw_rect(Rect2(rx, ry, 1, 5), C_RAIN)
		if i % 5 == 0:
			draw_rect(Rect2(rx - 1, ry + 1, 1, 3), Color(C_RAIN.r, C_RAIN.g, C_RAIN.b, 0.25))
