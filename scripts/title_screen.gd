extends Control

const SAVE_PATH := "user://fase1_save.json"
const ITEM_Y    := [113.0, 128.0, 143.0, 158.0]
const CURSOR_X  := 122.0

var _selected      := 0
var _transitioning := false
var _credits_open  := false
var _can_continue  := false

@onready var title_image:   TextureRect = $TitleImage
@onready var cursor:        Label       = $Cursor
@onready var credits_panel: ColorRect   = $CreditsPanel

@onready var _items: Array[Label] = [
	$MenuNovoJogo,
	$MenuContinuar,
	$MenuCreditos,
	$MenuSair,
]


func _ready() -> void:
	_can_continue = FileAccess.file_exists(SAVE_PATH)

	if ResourceLoader.exists("res://title_screen.png"):
		title_image.texture = load("res://title_screen.png")

	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 1.5)
	_update_cursor()


func _input(event: InputEvent) -> void:
	if _transitioning or event is InputEventMouseMotion:
		return

	if _credits_open:
		if event.is_action_pressed("ui_cancel") and not event.is_echo():
			_close_credits()
		return

	if event.is_action_pressed("ui_up") and not event.is_echo():
		_move_cursor(-1)
	elif event.is_action_pressed("ui_down") and not event.is_echo():
		_move_cursor(1)
	elif (event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")) and not event.is_echo():
		_select()


func _move_cursor(dir: int) -> void:
	var n := _items.size()
	_selected = (_selected + dir + n) % n
	# pula "Continuar" se não houver save
	if _selected == 1 and not _can_continue:
		_selected = (_selected + dir + n) % n
	_update_cursor()


func _update_cursor() -> void:
	cursor.position = Vector2(CURSOR_X, ITEM_Y[_selected])
	for i in _items.size():
		var lbl: Label = _items[i]
		if i == _selected:
			lbl.modulate = Color(1.0, 0.95, 0.45, 1.0)
		elif i == 1 and not _can_continue:
			lbl.modulate = Color(0.5, 0.5, 0.5, 0.35)
		else:
			lbl.modulate = Color(0.88, 0.88, 0.88, 0.80)


func _select() -> void:
	match _selected:
		0: _novo_jogo()
		1: if _can_continue: _continuar()
		2: _open_credits()
		3: _sair()


func _novo_jogo() -> void:
	_transitioning = true
	if FileAccess.file_exists(SAVE_PATH):
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove("fase1_save.json")
	GameGlobal.next_phase_number = 1
	GameGlobal.next_phase_name   = "Ecos do Silêncio"
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 1.2)
	tw.tween_callback(func() -> void:
		get_tree().change_scene_to_file("res://scenes/phase_intro.tscn")
	)


func _continuar() -> void:
	_transitioning = true
	GameGlobal.next_phase_number = 1
	GameGlobal.next_phase_name   = "Ecos do Silêncio"
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 1.2)
	tw.tween_callback(func() -> void:
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
