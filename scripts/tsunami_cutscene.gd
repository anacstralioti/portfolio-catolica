extends Node2D

## Pixel-art tsunami cutscene — transição entre Fase 1 e Fase 2

# ── Paleta ───────────────────────────────────────────────────────────
const C_SKY_TOP      := Color(0.04,  0.04,  0.10)   # topo do céu — quase preto
const C_SKY_MID      := Color(0.10,  0.10,  0.22)   # meio — escuro
const C_SKY_HORIZON  := Color(0.26,  0.24,  0.46)   # horizonte — roxo-acinzentado claro
const C_CLOUD_DARK   := Color(0.14,  0.13,  0.30)   # nuvens escuras
const C_CLOUD_LIGHT  := Color(0.32,  0.30,  0.56)   # nuvens claras — visíveis contra o céu
const C_OCEAN        := Color(0.02,  0.06,  0.14)   # oceano profundo
const C_OCEAN2       := Color(0.06,  0.16,  0.32)   # reflexo
const C_WAVE_SHADOW  := Color(0.01,  0.05,  0.16)   # sombra/costas da onda
const C_WAVE_A       := Color(0.04,  0.14,  0.34)   # corpo traseiro
const C_WAVE_B       := Color(0.07,  0.30,  0.56)   # corpo médio
const C_WAVE_C       := Color(0.12,  0.52,  0.76)   # face frontal — azul vivo
const C_WAVE_D       := Color(0.22,  0.74,  0.90)   # frente brilhante — ciano
const C_FOAM         := Color(0.80,  0.96,  0.98)   # espuma
const C_WHITE        := Color(1.00,  1.00,  1.00)   # branco puro
const C_SAND_D       := Color(0.42,  0.35,  0.25)
const C_SAND_M       := Color(0.55,  0.45,  0.33)
const C_SAND_L       := Color(0.66,  0.57,  0.42)
const C_FLOOD        := Color(0.04,  0.15,  0.25)
const C_RAIN         := Color(0.50,  0.68,  0.83, 0.55)

# ── Estado ───────────────────────────────────────────────────────────
var wave_x    := 380.0
var wave_h    := 8.0
var phase     := 0
var flood_lvl := 0.0
var time      := 0.0
var lightning := 0.0

@onready var screen_fade: ColorRect = $FadeLayer/ScreenFade


func _ready() -> void:
	screen_fade.modulate.a = 0.0
	_run_sequence()


func _run_sequence() -> void:
	var tw := create_tween()

	tw.tween_method(_set_wave,
		Vector2(380.0, 8.0), Vector2(85.0, 100.0), 4.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tw.tween_callback(func() -> void: phase = 1)
	tw.tween_method(_set_wave,
		Vector2(85.0, 100.0), Vector2(-90.0, 20.0), 1.2
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	tw.tween_callback(func() -> void: phase = 2; _shake())
	tw.tween_property(self, "flood_lvl", 1.0, 2.5)

	tw.tween_callback(func() -> void: phase = 3)
	tw.tween_property(screen_fade, "modulate:a", 1.0, 2.5)
	tw.tween_interval(0.4)
	tw.tween_callback(_transition)


func _set_wave(v: Vector2) -> void:
	wave_x = v.x
	wave_h  = v.y


func _shake() -> void:
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
	lightning = maxf(0.0, lightning - delta * 5.0)
	if randf() < 0.004 and phase < 3:
		lightning = randf_range(0.5, 0.9)
	queue_redraw()


# ─────────────────────────────────────────────────────────────────────
func _draw() -> void:
	var W       := 320.0
	var H       := 180.0
	var HORIZON := 108.0
	var GROUND  := 140.0

	_draw_sky(W, HORIZON)
	_draw_ocean(W, HORIZON, GROUND)
	_draw_beach(W, GROUND, H)
	if phase <= 1:
		_draw_wave(W, GROUND)
	_draw_flood(W, GROUND, H)
	_draw_rain(W, H)

	if lightning > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(0.85, 0.90, 1.0, lightning * 0.30))


# ── Céu ──────────────────────────────────────────────────────────────
func _draw_sky(W: float, horizon: float) -> void:
	# Degradê do topo ao horizonte em 4 bandas — horizonte bem mais claro
	draw_rect(Rect2(0, 0,              W, horizon * 0.40), C_SKY_TOP)
	draw_rect(Rect2(0, horizon * 0.40, W, horizon * 0.25), C_SKY_MID)
	draw_rect(Rect2(0, horizon * 0.65, W, horizon * 0.20), Color(0.17, 0.16, 0.34))
	draw_rect(Rect2(0, horizon * 0.85, W, horizon * 0.15), C_SKY_HORIZON)

	# Nuvens volumosas — mais visíveis contra o céu mais claro
	var clouds := [
		[0,    8,  70, 16],
		[8,    4,  40,  8],
		[60,  18,  80, 18],
		[68,  14,  52,  8],
		[148,  6,  96, 22],
		[156,  2,  64, 10],
		[252, 20,  60, 16],
		[260, 16,  38,  8],
	]
	for c in clouds:
		draw_rect(Rect2(c[0],   c[1],   c[2], c[3]), C_CLOUD_DARK)
		draw_rect(Rect2(c[0]+4, c[1]-4, c[2]-8, 5),  C_CLOUD_LIGHT)

	if lightning > 0.35:
		draw_rect(Rect2(138, 44, 3, 16), C_WHITE)
		draw_rect(Rect2(144, 58, 3, 13), C_WHITE)
		draw_rect(Rect2(136, 69, 4, 11), C_WHITE)


# ── Oceano ───────────────────────────────────────────────────────────
func _draw_ocean(W: float, horizon: float, ground: float) -> void:
	draw_rect(Rect2(0, horizon, W, ground - horizon), C_OCEAN)
	for i in range(5):
		var off := fmod(time * (16.0 + i * 5.0) + i * 22.0, W + 24.0)
		var ry  := horizon + 5.0 + i * 6.0
		draw_rect(Rect2(W - off,      ry, 20, 2), C_OCEAN2)
		draw_rect(Rect2(W - off - 18, ry + 1, 9, 1), C_OCEAN2)


# ── Praia ────────────────────────────────────────────────────────────
func _draw_beach(W: float, ground: float, H: float) -> void:
	var bh := H - ground
	draw_rect(Rect2(0, ground, W, bh), C_SAND_M)
	draw_rect(Rect2(0, ground, W,  5), C_SAND_L)
	for ix in range(0, int(W), 14):
		for iy in range(2, int(bh), 10):
			if (ix * 7 + iy * 3) % 17 < 6:
				draw_rect(Rect2(ix + 3, ground + iy + 1, 3, 2), C_SAND_D)


# ── Onda ─────────────────────────────────────────────────────────────
func _draw_wave(W: float, ground: float) -> void:
	if wave_x > W + 12:
		return

	var wh  := wave_h
	var ww  := 44.0 + wh * 0.58
	var wx  := wave_x
	var top := ground - wh

	# Rasto de água atrás
	if wx < W:
		var trail := clampf(wx + ww * 0.50, 0.0, W)
		draw_rect(Rect2(trail, ground - 10, W - trail, 10), C_WAVE_A)

	# ── Corpo: costas (sombra) → frente (brilhante) ──────────────────
	# Sombra mais escura nas costas — define a forma da onda
	draw_rect(Rect2(wx + ww * 0.20, top,           ww * 0.80, wh),           C_WAVE_SHADOW)
	# Corpo traseiro
	draw_rect(Rect2(wx + ww * 0.10, top,           ww * 0.68, wh),           C_WAVE_A)
	# Corpo médio
	draw_rect(Rect2(wx - ww * 0.02, top + wh*0.18, ww * 0.58, wh * 0.82),   C_WAVE_B)
	# Face frontal brilhante — principal cor visível
	draw_rect(Rect2(wx - ww * 0.16, top + wh*0.38, ww * 0.46, wh * 0.62),   C_WAVE_C)
	# Frente inferior ciano — contraste máximo com a areia
	draw_rect(Rect2(wx - ww * 0.26, top + wh*0.62, ww * 0.34, wh * 0.38),   C_WAVE_D)

	# ── Contorno escuro na aresta frontal (silhueta clara) ───────────
	var edge := maxf(3.0, wh * 0.045)
	draw_rect(Rect2(wx - ww * 0.28, top + wh * 0.28, edge, wh * 0.72 + 8), C_WAVE_SHADOW)

	# ── Crista visível desde o início (escala com altura) ────────────
	var cw := clampf(wh / 50.0, 0.15, 1.0)  # fator de escala 0–1
	var cy := top - 2.0
	draw_rect(Rect2(wx + ww*0.08,  cy,     ww * 0.30 * cw, 4), C_WAVE_D)
	draw_rect(Rect2(wx + ww*0.02,  cy - 4, ww * 0.22 * cw, 4), C_FOAM)
	draw_rect(Rect2(wx - ww*0.04,  cy - 8, ww * 0.14 * cw, 3), C_WHITE)
	if wh > 30.0:
		draw_rect(Rect2(wx - ww*0.09, cy -11, ww * 0.08 * cw, 3), C_WHITE)

	# ── Espuma na base ────────────────────────────────────────────────
	var fs := wx - ww * 0.28
	var fw := ww * 0.40
	draw_rect(Rect2(fs,     ground - 9, fw,       9), C_FOAM)
	draw_rect(Rect2(fs + 2, ground - 4, fw * 0.6, 4), C_WHITE)

	# ── Spray no impacto ─────────────────────────────────────────────
	if phase == 1 and wh > 12.0:
		for i in range(14):
			var t_s   := fmod(time * 4.5 + i * 0.12, 1.0)
			var angle := -PI * 0.85 + i * (PI * 0.65 / 13.0)
			var dx    := wx + cos(angle) * wh * t_s
			var dy    := top  + sin(angle) * wh * t_s
			draw_rect(Rect2(dx, dy, 2, 2), C_WHITE)
			if t_s < 0.5:
				draw_rect(Rect2(dx + 1, dy - 2, 2, 2), C_FOAM)


# ── Inundação ────────────────────────────────────────────────────────
func _draw_flood(W: float, ground: float, H: float) -> void:
	if flood_lvl <= 0.0:
		return
	var fh    := flood_lvl * (H - ground) * 0.62
	var fy    := H - fh
	var alpha := minf(flood_lvl * 1.5, 0.88)
	draw_rect(Rect2(0, fy, W, fh), Color(C_FLOOD.r, C_FLOOD.g, C_FLOOD.b, alpha))
	if flood_lvl > 0.12:
		for ix in range(0, int(W), 22):
			var ox := fmod(time * 22.0 + ix * 4.0, W + 22.0) - 11.0
			draw_rect(Rect2(ox,     fy, 11, 2), Color(C_FOAM.r,  C_FOAM.g,  C_FOAM.b,  0.70))
			draw_rect(Rect2(ox + 4, fy,  5, 1), Color(C_WHITE.r, C_WHITE.g, C_WHITE.b, 0.50))


# ── Chuva ────────────────────────────────────────────────────────────
func _draw_rain(W: float, H: float) -> void:
	if phase >= 3:
		return
	for i in range(40):
		var rx := fmod(i * 8.3  + time * 26.0, W)
		var ry := fmod(i * 4.7  + time * (85.0 + i * 0.65), H)
		draw_rect(Rect2(rx, ry, 1, 5), C_RAIN)
