extends CanvasLayer

# Menu de pausa, 2 modos: MAIN (3 opções) e CONFIRM (confirmação de ação destrutiva).
# Usa process_mode = ALWAYS para capturar input mesmo com get_tree().paused = true.

enum Mode { MAIN, CONFIRM }

# Posições Y dos itens no canvas (pixel art 320×180)
const ITEM_Y   := [65.0, 83.0, 101.0]
const CURSOR_X := 100.0

const CONFIRM_Y := [100.0, 114.0]
const CONFIRM_X := 100.0

var _mode    := Mode.MAIN
var _selected      := 0
var _confirm_sel   := 0
var _confirm_action := ""  # "menu" ou "quit", determina o que executar ao confirmar

@onready var cursor:  Label = $UI/Cursor
@onready var _items: Array[Label] = [
	$UI/OptContinuar,
	$UI/OptMenu,
	$UI/OptSair,
]

@onready var confirm_panel:   Control = $UI/ConfirmPanel
@onready var confirm_cursor:  Label   = $UI/ConfirmPanel/ConfirmCursor
@onready var confirm_sim:     Label   = $UI/ConfirmPanel/ConfirmOptSim
@onready var confirm_nao:     Label   = $UI/ConfirmPanel/ConfirmOptNao


func _ready() -> void:
	# PROCESS_MODE_ALWAYS: garante que o menu responde mesmo com o jogo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	confirm_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	# Hover do mouse funciona mesmo com o menu fechado (para não perder posição)
	if event is InputEventMouseMotion:
		if visible:
			_on_mouse_hover(event.position)
		return

	# Pressionar ESC com o menu fechado tenta abrir (se não há overlay aberto)
	if not visible:
		if event.is_action_pressed("ui_cancel") and not event.is_echo():
			_try_open()
		return

	# Consome o input quando o menu está aberto (impede que chegue ao jogo)
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_mouse_click(event.position)
		return

	if _mode == Mode.MAIN:
		if (_is_nav(event, KEY_W) or (event.is_action_pressed("ui_up") and not event.is_echo())):
			_move(-1)
		elif (_is_nav(event, KEY_S) or (event.is_action_pressed("ui_down") and not event.is_echo())):
			_move(1)
		elif (event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")) and not event.is_echo():
			_select()
		elif event.is_action_pressed("ui_cancel") and not event.is_echo():
			_resume()
	else:
		if (_is_nav(event, KEY_W) or (event.is_action_pressed("ui_up") and not event.is_echo())):
			_confirm_move(-1)
		elif (_is_nav(event, KEY_S) or (event.is_action_pressed("ui_down") and not event.is_echo())):
			_confirm_move(1)
		elif (event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")) and not event.is_echo():
			_confirm_select()
		elif event.is_action_pressed("ui_cancel") and not event.is_echo():
			_confirm_cancel()


func _is_nav(event: InputEvent, keycode: int) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == keycode


func _on_mouse_hover(pos: Vector2) -> void:
	if _mode == Mode.CONFIRM:
		if confirm_sim.get_global_rect().has_point(pos) and _confirm_sel != 0:
			_confirm_sel = 0
			_confirm_update()
		elif confirm_nao.get_global_rect().has_point(pos) and _confirm_sel != 1:
			_confirm_sel = 1
			_confirm_update()
	else:
		for i in _items.size():
			if _items[i].get_global_rect().has_point(pos):
				if _selected != i:
					_selected = i
					_update_cursor()
				break


func _on_mouse_click(pos: Vector2) -> void:
	if _mode == Mode.CONFIRM:
		if confirm_sim.get_global_rect().has_point(pos):
			_confirm_sel = 0
			_confirm_update()
			_confirm_select()
		elif confirm_nao.get_global_rect().has_point(pos):
			_confirm_sel = 1
			_confirm_update()
			_confirm_select()
	else:
		for i in _items.size():
			if _items[i].get_global_rect().has_point(pos):
				_selected = i
				_update_cursor()
				_select()
				break


func _try_open() -> void:
	# Não abre o menu se há um overlay (foto, diário, flashback) em cima
	var root := get_tree().root
	for oname in ["PhotoOverlay", "DiaryOverlay", "FlashbackOverlay"]:
		if root.get_node_or_null(oname):
			return
	_mode = Mode.MAIN
	_selected = 0
	confirm_panel.visible = false
	_update_cursor()
	visible = true
	get_tree().paused = true


func _resume() -> void:
	confirm_panel.visible = false
	_mode = Mode.MAIN
	visible = false
	get_tree().paused = false


func _move(dir: int) -> void:
	_selected = (_selected + dir + _items.size()) % _items.size()
	_update_cursor()


func _update_cursor() -> void:
	cursor.position = Vector2(CURSOR_X, ITEM_Y[_selected])
	for i in _items.size():
		_items[i].modulate = Color(1.0, 0.95, 0.45, 1.0) if i == _selected else Color(0.88, 0.88, 0.88, 0.85)


func _select() -> void:
	match _selected:
		0: _resume()
		1: _open_confirm("menu")
		2: _open_confirm("quit")


func _open_confirm(action: String) -> void:
	# Abre painel de confirmação, "Não" fica pré-selecionado para evitar saída acidental
	_confirm_action = action
	_confirm_sel = 1
	_mode = Mode.CONFIRM
	confirm_panel.visible = true
	_confirm_update()


func _confirm_cancel() -> void:
	confirm_panel.visible = false
	_mode = Mode.MAIN
	_update_cursor()


func _confirm_move(dir: int) -> void:
	_confirm_sel = (_confirm_sel + dir + 2) % 2
	_confirm_update()


func _confirm_update() -> void:
	confirm_cursor.position = Vector2(CONFIRM_X, CONFIRM_Y[_confirm_sel])
	confirm_sim.modulate = Color(1.0, 0.95, 0.45, 1.0) if _confirm_sel == 0 else Color(0.88, 0.88, 0.88, 0.85)
	confirm_nao.modulate = Color(1.0, 0.95, 0.45, 1.0) if _confirm_sel == 1 else Color(0.88, 0.88, 0.88, 0.85)


func _confirm_select() -> void:
	if _confirm_sel == 0:  # "Sim" selecionado
		match _confirm_action:
			"menu": _to_menu()
			"quit": _quit()
	else:                  # "Não", volta ao menu de pausa
		_confirm_cancel()


func _to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _quit() -> void:
	get_tree().paused = false
	get_tree().quit()
