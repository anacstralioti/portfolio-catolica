extends Control

# Menu principal, seleção de slot de save, créditos e saída.
# Suporta navegação por teclado (setas/WS) e mouse (hover + clique).

const SAVE_PATH_TPL := "user://fase1_save_slot%d.json"
const MAX_SLOTS     := 3

# Posições Y dos itens do menu principal (em pixels do canvas 320×180)
const ITEM_Y   := [111.0, 122.0, 133.0, 144.0]
const CURSOR_X := 225.0  # posição X do cursor "►" no menu principal

# Posições Y dos slots de save no painel lateral
const SLOT_Y  := [70.0, 96.0, 122.0]
const SLOT_CX := 58.0   # posição X do cursor de slot

# ── Estado interno ────────────────────────────────────────────────────────────
var _selected       := 0       # índice do item selecionado no menu principal
var _transitioning  := false   # bloqueia input durante fade de transição
var _credits_open   := false
var _in_slot_panel  := false
var _slot_selected  := 0
var _slot_mode      := ""      # "new" ou "continue"
var _slot_has_save  : Array[bool] = [false, false, false]
var _can_continue   := false   # false se todos os slots estiverem vazios

@onready var title_image:   TextureRect = $TitleImage
@onready var _title_lbl:    Label       = $TitleLabel
@onready var cursor:        Label       = $Cursor
@onready var credits_panel: ColorRect   = $CreditsPanel
@onready var slot_panel:    ColorRect   = $SaveSlotPanel
@onready var slot_cursor:   Label       = $SaveSlotPanel/SlotCursor
@onready var slot_title:    Label       = $SaveSlotPanel/SlotTitle
@onready var slot_hint:     Label       = $SaveSlotPanel/SlotHint
@onready var _slot_lbl: Array[Label] = [
	$SaveSlotPanel/Slot1Label,
	$SaveSlotPanel/Slot2Label,
	$SaveSlotPanel/Slot3Label,
]
@onready var _items: Array[Label] = [
	$MenuNovoJogo,
	$MenuContinuar,
	$MenuCreditos,
	$MenuSair,
]


func _ready() -> void:
	# Verifica quais slots têm arquivo de save para habilitar "Continuar"
	for i in MAX_SLOTS:
		_slot_has_save[i] = FileAccess.file_exists(SAVE_PATH_TPL % (i + 1))
	for v in _slot_has_save:
		if v:
			_can_continue = true
			break

	if ResourceLoader.exists("res://title_screen.png"):
		title_image.texture = load("res://title_screen.png")

	# Fade-in da tela ao iniciar
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 1.5)
	_update_cursor()

	# Animação de shimmer no título ICHIGO, pulsa entre dourado e creme em loop
	var tw_sh := create_tween().set_loops()
	tw_sh.tween_property(_title_lbl, "self_modulate", Color(1, 0.82, 0.45, 1), 2.2).set_trans(Tween.TRANS_SINE)
	tw_sh.tween_property(_title_lbl, "self_modulate", Color(1, 0.97, 0.80, 1), 2.2).set_trans(Tween.TRANS_SINE)


func _get_slot_info(idx: int) -> String:
	if not _slot_has_save[idx]:
		return "Slot %d — [Vazio]" % (idx + 1)
	var f := FileAccess.open(SAVE_PATH_TPL % (idx + 1), FileAccess.READ)
	if not f:
		return "Slot %d — [Erro]" % (idx + 1)
	var j := JSON.new()
	if j.parse(f.get_as_text()) != OK:
		f.close()
		return "Slot %d — [Corrompido]" % (idx + 1)
	f.close()
	var d: Dictionary = j.get_data()
	var pct := int(d.get("progress", 0.0) * 100.0)
	var chk := int(d.get("checkpoints", 0))
	return "Slot %d — %d%%  CP:%d" % [idx + 1, pct, chk]


func _input(event: InputEvent) -> void:
	if _transitioning: return

	# Mouse hover e clique são tratados separadamente do teclado
	if event is InputEventMouseMotion:
		_on_mouse_hover(event.position)
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_mouse_click(event.position)
		return

	# Créditos abertos, só ESC fecha
	if _credits_open:
		if event.is_action_pressed("ui_cancel") and not event.is_echo():
			_close_credits()
		return

	# Painel de slots aberto, navegação entre slots
	if _in_slot_panel:
		if (_is_nav(event, KEY_W) or (event.is_action_pressed("ui_up") and not event.is_echo())):
			_move_slot_cursor(-1)
		elif (_is_nav(event, KEY_S) or (event.is_action_pressed("ui_down") and not event.is_echo())):
			_move_slot_cursor(1)
		elif (event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")) and not event.is_echo():
			_confirm_slot()
		elif event.is_action_pressed("ui_cancel") and not event.is_echo():
			_close_slot_panel()
		elif event is InputEventKey and event.pressed and not event.echo:
			if (event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE) and _slot_mode == "continue":
				_delete_current_slot()
		return

	# Menu principal
	if (_is_nav(event, KEY_W) or (event.is_action_pressed("ui_up") and not event.is_echo())):
		_move_cursor(-1)
	elif (_is_nav(event, KEY_S) or (event.is_action_pressed("ui_down") and not event.is_echo())):
		_move_cursor(1)
	elif (event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")) and not event.is_echo():
		_select()


# Detecta W/S fora do Input Map para evitar conflito com as ações de movimento
func _is_nav(event: InputEvent, keycode: int) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == keycode


func _on_mouse_hover(pos: Vector2) -> void:
	if _credits_open: return
	if _in_slot_panel:
		for i in MAX_SLOTS:
			if not _slot_lbl[i].visible: continue
			if _slot_mode == "continue" and not _slot_has_save[i]: continue
			if _slot_lbl[i].get_global_rect().has_point(pos):
				if _slot_selected != i:
					_slot_selected = i
					_update_slot_cursor()
				break
		return
	for i in _items.size():
		if _items[i].get_global_rect().has_point(pos):
			if i == 1 and not _can_continue: break
			if _selected != i:
				_selected = i
				_update_cursor()
			break


func _on_mouse_click(pos: Vector2) -> void:
	if _credits_open:
		_close_credits()
		return
	if _in_slot_panel:
		for i in MAX_SLOTS:
			if not _slot_lbl[i].visible: continue
			if _slot_mode == "continue" and not _slot_has_save[i]: continue
			if _slot_lbl[i].get_global_rect().has_point(pos):
				_slot_selected = i
				_update_slot_cursor()
				_confirm_slot()
				return
		if not slot_panel.get_global_rect().has_point(pos):
			_close_slot_panel()
		return
	for i in _items.size():
		if _items[i].get_global_rect().has_point(pos):
			if i == 1 and not _can_continue: return
			_selected = i
			_update_cursor()
			_select()
			return


func _move_cursor(dir: int) -> void:
	var n := _items.size()
	_selected = (_selected + dir + n) % n
	# Pula "Continuar" se não há saves disponíveis
	if _selected == 1 and not _can_continue:
		_selected = (_selected + dir + n) % n
	_update_cursor()


func _update_cursor() -> void:
	cursor.position = Vector2(CURSOR_X, ITEM_Y[_selected])
	for i in _items.size():
		var lbl: Label = _items[i]
		if i == _selected:
			lbl.modulate = Color(1.0, 0.95, 0.45, 1.0)   # dourado = selecionado
		elif i == 1 and not _can_continue:
			lbl.modulate = Color(0.5, 0.5, 0.5, 0.35)    # cinza = desabilitado
		else:
			lbl.modulate = Color(0.88, 0.88, 0.88, 0.80)  # branco suave = normal


func _select() -> void:
	match _selected:
		0: _open_slot_panel("new")
		1: if _can_continue: _open_slot_panel("continue")
		2: _open_credits()
		3: _sair()


func _open_slot_panel(mode: String) -> void:
	_slot_mode     = mode
	_slot_selected = 0

	if mode == "new":
		# Posiciona o cursor no primeiro slot vazio
		var found := false
		for i in MAX_SLOTS:
			if not _slot_has_save[i]:
				_slot_selected = i
				found = true
				break
		if not found: return  # todos os slots ocupados, não abre o painel
		slot_title.visible = false
		slot_hint.text     = "[E] Selecionar   [ESC] Voltar"
	else:
		# Posiciona o cursor no primeiro slot com save
		for i in MAX_SLOTS:
			if _slot_has_save[i]:
				_slot_selected = i
				break
		slot_title.visible = true
		slot_title.text    = "Escolher slot"
		slot_hint.text     = "[E] Selecionar   [DEL] Apagar   [ESC] Voltar"

	_in_slot_panel = true
	_refresh_slot_labels()
	_update_slot_cursor()
	slot_panel.visible    = true
	slot_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(slot_panel, "modulate:a", 1.0, 0.25)


func _refresh_slot_labels() -> void:
	for i in MAX_SLOTS:
		if _slot_mode == "new" and _slot_has_save[i]:
			_slot_lbl[i].visible = false  # esconde slots ocupados no modo Novo Jogo
		else:
			_slot_lbl[i].visible = true
			_slot_lbl[i].text = _get_slot_info(i)


func _move_slot_cursor(dir: int) -> void:
	var next := (_slot_selected + dir + MAX_SLOTS) % MAX_SLOTS
	if _slot_mode == "continue":
		# Pula slots vazios no modo Continuar
		var tries := 0
		while not _slot_has_save[next] and tries < MAX_SLOTS:
			next = (next + dir + MAX_SLOTS) % MAX_SLOTS
			tries += 1
		if not _slot_has_save[next]: return
	elif _slot_mode == "new":
		# Pula slots já ocupados no modo Novo Jogo
		var tries := 0
		while _slot_has_save[next] and tries < MAX_SLOTS:
			next = (next + dir + MAX_SLOTS) % MAX_SLOTS
			tries += 1
		if _slot_has_save[next]: return
	_slot_selected = next
	_update_slot_cursor()


func _update_slot_cursor() -> void:
	slot_cursor.position = Vector2(SLOT_CX, SLOT_Y[_slot_selected])
	for i in MAX_SLOTS:
		var lbl: Label = _slot_lbl[i]
		if _slot_mode == "new":
			if _slot_has_save[i]:
				lbl.visible = false
				continue
			lbl.visible  = true
			lbl.modulate = Color(1.0, 0.95, 0.45, 1.0) if i == _slot_selected else Color(0.88, 0.88, 0.88, 0.80)
		else:
			lbl.visible = true
			var empty_in_continue := not _slot_has_save[i]
			if i == _slot_selected and not empty_in_continue:
				lbl.modulate = Color(1.0, 0.95, 0.45, 1.0)
			elif empty_in_continue:
				lbl.modulate = Color(0.5, 0.5, 0.5, 0.35)  # slot vazio = inativo
			else:
				lbl.modulate = Color(0.88, 0.88, 0.88, 0.80)


func _confirm_slot() -> void:
	# Validações de segurança, evitam estado inconsistente
	if _slot_mode == "continue" and not _slot_has_save[_slot_selected]: return
	if _slot_mode == "new"      and     _slot_has_save[_slot_selected]: return
	GameGlobal.current_save_slot = _slot_selected + 1
	_transitioning = true
	if _slot_mode == "new":
		_start_new_game()
	else:
		_start_continue()


func _delete_current_slot() -> void:
	if not _slot_has_save[_slot_selected]: return
	var dir := DirAccess.open("user://")
	if dir:
		dir.remove("fase1_save_slot%d.json" % (_slot_selected + 1))
	_slot_has_save[_slot_selected] = false
	# Recalcula se ainda existe algum save disponível
	_can_continue = false
	for v in _slot_has_save:
		if v:
			_can_continue = true
			break
	_refresh_slot_labels()
	_update_slot_cursor()
	_update_cursor()
	if _slot_mode == "continue" and not _can_continue:
		_close_slot_panel()
	elif _slot_mode == "continue" and not _slot_has_save[_slot_selected]:
		_move_slot_cursor(1)


func _close_slot_panel() -> void:
	_in_slot_panel = false
	var tw := create_tween()
	tw.tween_property(slot_panel, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func() -> void: slot_panel.visible = false)


func _start_new_game() -> void:
	# Apaga o save existente no slot escolhido antes de começar
	var path := SAVE_PATH_TPL % GameGlobal.current_save_slot
	if FileAccess.file_exists(path):
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove("fase1_save_slot%d.json" % GameGlobal.current_save_slot)
	GameGlobal.next_phase_number = 1
	GameGlobal.next_phase_name   = "Ecos do Silêncio"
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 1.2)
	tw.tween_callback(func() -> void:
		get_tree().change_scene_to_file("res://scenes/phase_intro.tscn")
	)


func _start_continue() -> void:
	GameGlobal.next_phase_number = 1
	GameGlobal.next_phase_name   = "Ecos do Silêncio"
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 1.2)
	tw.tween_callback(func() -> void:
		# Continuar vai direto para a fase, sem a tela de introdução
		get_tree().change_scene_to_file("res://scenes/fase1_ecos_silencio.tscn")
	)


func _open_credits() -> void:
	_credits_open        = true
	credits_panel.visible    = true
	credits_panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(credits_panel, "modulate:a", 1.0, 0.35)


func _close_credits() -> void:
	_credits_open = false
	var tw := create_tween()
	tw.tween_property(credits_panel, "modulate:a", 0.0, 0.25)
	tw.tween_callback(func() -> void: credits_panel.visible = false)


func _sair() -> void:
	_transitioning = true
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.8)
	tw.tween_callback(func() -> void: get_tree().quit())
