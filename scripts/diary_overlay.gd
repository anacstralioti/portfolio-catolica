extends CanvasLayer

# Overlay do diário, mostra as páginas rasuradas da memória de Ichigo.
# Todo o layout (margens, borrões de tinta, manchas d'água) é calculado
# dinamicamente em _layout() para funcionar em qualquer resolução.

@onready var root:       Control   = $Root
@onready var page:       ColorRect = $Root/Page
@onready var stain_a:   ColorRect = $Root/WaterStainA   # mancha d'água maior
@onready var stain_b:   ColorRect = $Root/WaterStainB   # mancha d'água menor
@onready var title_lbl: Label     = $Root/Title
@onready var read1:     Label     = $Root/ReadLine1      # linhas de texto da entrada
@onready var read2:     Label     = $Root/ReadLine2
@onready var read3:     Label     = $Root/ReadLine3
@onready var close_hint:Label     = $Root/CloseHint      # "[E] Fechar"

# Bloqueia fechar por 0.9s para evitar fechar acidentalmente ao abrir
var _can_close := false


func _ready() -> void:
	root.modulate.a = 0.0
	_layout()
	# Sequência: fade-in → pausa 0.9s → libera fechar
	var tw := create_tween()
	tw.tween_property(root, "modulate:a", 1.0, 0.55)
	tw.tween_interval(0.9)
	tw.tween_callback(func() -> void: _can_close = true)


func _layout() -> void:
	# Layout responsivo: calcula tamanho e posição da página relativo ao viewport
	var vp := get_viewport().get_visible_rect().size
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$Root/Dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Página ocupa 66% da largura e 88% da altura do viewport
	var pw := vp.x * 0.66
	var ph := vp.y * 0.88
	var px := (vp.x - pw) * 0.5
	var py := (vp.y - ph) * 0.5

	page.position = Vector2(px, py)
	page.size     = Vector2(pw, ph)

	var pad_x := pw * 0.08
	var pad_y := ph * 0.05
	var iw    := pw - pad_x * 2.0
	var fs    := maxi(8, int(vp.x / 40))    # tamanho de fonte escala com viewport
	var lh    := float(fs) * 1.35            # altura de linha

	stain_a.position = Vector2(px + pad_x, py + ph * 0.10)
	stain_a.size     = Vector2(iw * 0.80, ph * 0.18)

	stain_b.position = Vector2(px + pad_x + iw * 0.10, py + ph * 0.36)
	stain_b.size     = Vector2(iw * 0.60, ph * 0.12)

	title_lbl.position = Vector2(px + pad_x, py + pad_y)
	title_lbl.size     = Vector2(iw, lh * 1.5)
	title_lbl.add_theme_font_size_override("font_size", fs)

	_place_smears(px, py, pw, ph, pad_x, iw, lh)

	# As três linhas de texto ficam na metade superior-central da página
	var r1y := py + ph * 0.28
	read1.position = Vector2(px + pad_x, r1y)
	read1.size     = Vector2(iw, lh * 1.5)
	read1.add_theme_font_size_override("font_size", fs)

	read2.position = Vector2(px + pad_x, r1y + lh * 1.5)
	read2.size     = Vector2(iw, lh * 1.5)
	read2.add_theme_font_size_override("font_size", fs)

	read3.position = Vector2(px + pad_x, py + ph * 0.52)
	read3.size     = Vector2(iw, lh * 1.5)
	read3.add_theme_font_size_override("font_size", fs)

	var hint_fs := maxi(7, int(vp.x / 50))
	var hint_h  := float(hint_fs) * 1.8
	close_hint.position = Vector2(px, py + ph - hint_h - 6.0)
	close_hint.size     = Vector2(pw, hint_h)
	close_hint.add_theme_font_size_override("font_size", hint_fs)


func _place_smears(px: float, py: float, _pw: float, ph: float, pad_x: float, iw: float, lh: float) -> void:
	# Posiciona os ColorRects de "linhas rasuradas" (nós Ink* na cena)
	# Simula texto escrito/apagado/borrado no diário da personagem
	var smears: Array[Node] = []
	for n in root.get_children():
		if n.name.begins_with("Ink"):
			smears.append(n)

	# Posições relativas à altura da página, larguras e opacidades variadas
	# para imitar texto real em densidade irregular
	var rows   := [0.155, 0.170, 0.210, 0.222, 0.258, 0.400, 0.412, 0.455, 0.575, 0.588, 0.630, 0.642]
	var widths := [0.75, 0.52, 0.46, 0.62, 0.38, 0.60, 0.50, 0.34, 0.66, 0.42, 0.36, 0.55]
	var alphas := [0.55, 0.32, 0.50, 0.26, 0.40, 0.48, 0.24, 0.36, 0.44, 0.20, 0.28, 0.38]
	var smear_h := maxf(1.0, lh * 0.18)  # altura de cada linha rasurada

	for i in mini(smears.size(), rows.size()):
		var r: ColorRect = smears[i] as ColorRect
		r.position = Vector2(px + pad_x, py + ph * rows[i])
		r.size     = Vector2(iw * widths[i], smear_h)
		r.color    = Color(0.08, 0.10, 0.22, alphas[i])


func _input(event: InputEvent) -> void:
	if not _can_close or event is InputEventMouseMotion:
		return
	if (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")) and not event.is_echo():
		_close()


func _close() -> void:
	_can_close = false
	var tw := create_tween()
	tw.tween_property(root, "modulate:a", 0.0, 0.4)
	tw.tween_callback(queue_free)
