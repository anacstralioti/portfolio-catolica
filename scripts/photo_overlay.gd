extends CanvasLayer

# Overlay de fotografia, exibe a foto coletada com moldura vintage e legenda.
# Layout calculado dinamicamente: funciona em 320×180 e em resoluções maiores.
# Re-examinável via inventário (GameGlobal.photo_texture persiste entre cenas).

@export var caption_text:    String    = ""   # texto da legenda abaixo da foto
@export var overlay_texture: Texture2D = null # textura da foto a ser exibida

@onready var root:        Control     = $Root
@onready var dimmer:      ColorRect   = $Root/Dimmer        # fundo escuro semitransparente
@onready var frame_outer: ColorRect   = $Root/FrameOuter    # moldura externa (mais escura)
@onready var frame_inner: ColorRect   = $Root/FrameInner    # passe-partout (mais claro)
@onready var photo_rect:  TextureRect = $Root/Photo         # a imagem em si
@onready var caption_lbl: Label       = $Root/Caption       # legenda manuscrita
@onready var divider:     ColorRect   = $Root/Divider       # linha entre foto e legenda
@onready var close_hint:  Label       = $Root/CloseHint     # "[E] Fechar", aparece após 0.7s

# Bloqueio anti-duplo-clique: impede fechar imediatamente ao abrir
var _can_close := false


func _ready() -> void:
	if overlay_texture:
		photo_rect.texture = overlay_texture
	close_hint.visible = false  # esconde o hint até 0.7s após abrir
	root.modulate.a = 0.0

	_layout()

	if not caption_text.is_empty():
		caption_lbl.text = caption_text

	# Sequência: fade-in (0.55s) → pausa (0.7s) → mostra hint + libera fechar
	var tw := create_tween()
	tw.tween_property(root, "modulate:a", 1.0, 0.55)
	tw.tween_interval(0.7)
	tw.tween_callback(func() -> void: close_hint.visible = true; _can_close = true)


func _layout() -> void:
	# Calcula moldura, passe-partout, legenda e hint adaptativamente.
	# border = borda da moldura; mat = largura do passe-partout.
	var vp := get_viewport().get_visible_rect().size
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var frame_w := vp.x * 0.62
	var border  := maxf(2.0, frame_w * 0.020)   # borda da moldura
	var mat     := maxf(3.0, frame_w * 0.028)   # passe-partout
	var inner_w := frame_w - (border + mat) * 2.0

	var fs_cap  := maxi(10, int(vp.x / 36))  # fonte da legenda (mínimo 10px)
	var fs_hint := maxi(8,  int(vp.x / 48))  # fonte do hint (mínimo 8px)

	var photo_h   := vp.y * 0.56
	var caption_h := float(fs_cap) * 1.35 * 3.0 + mat * 1.5  # 3 linhas de legenda
	var hint_h    := float(fs_hint) * 1.5
	var frame_h   := border * 2.0 + mat * 2.0 + photo_h + caption_h + hint_h + 4.0

	# Se a moldura não couber verticalmente, escala tudo proporcionalmente
	if frame_h > vp.y - 4.0:
		var scale := (vp.y - 4.0) / frame_h
		photo_h   *= scale
		caption_h *= scale
		hint_h    *= scale
		frame_h    = vp.y - 4.0

	var fx := (vp.x - frame_w) * 0.5
	var fy := (vp.y - frame_h) * 0.5

	frame_outer.position = Vector2(fx, fy)
	frame_outer.size     = Vector2(frame_w, frame_h)

	frame_inner.position = Vector2(fx + border, fy + border)
	frame_inner.size     = Vector2(frame_w - border * 2.0, frame_h - border * 2.0)

	var photo_x := fx + border + mat
	var photo_y := fy + border + mat
	photo_rect.position = Vector2(photo_x, photo_y)
	photo_rect.size     = Vector2(inner_w, photo_h)

	var div_y := photo_y + photo_h + mat * 0.5
	divider.position = Vector2(photo_x + inner_w * 0.05, div_y)
	divider.size     = Vector2(inner_w * 0.90, 1.0)

	close_hint.position = Vector2(fx + border, div_y + 2.0)
	close_hint.size     = Vector2(frame_w - border * 2.0, hint_h)
	close_hint.add_theme_font_size_override("font_size", fs_hint)

	caption_lbl.position      = Vector2(photo_x, div_y + hint_h + 4.0)
	caption_lbl.size          = Vector2(inner_w, caption_h)
	caption_lbl.clip_contents = false
	caption_lbl.add_theme_font_size_override("font_size", fs_cap)
	caption_lbl.add_theme_color_override("font_color", Color(0.22, 0.14, 0.06, 0.92))


func _input(event: InputEvent) -> void:
	if not _can_close or event is InputEventMouseMotion:
		return
	if (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")) and not event.is_echo():
		_close()


func _close() -> void:
	_can_close = false
	var tw := create_tween()
	tw.tween_property(root, "modulate:a", 0.0, 0.45)
	tw.tween_callback(queue_free)
