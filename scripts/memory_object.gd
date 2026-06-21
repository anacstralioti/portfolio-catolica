extends Node2D

# Objeto de memória genérico e configurável via @export no Editor.
# Centraliza toda a lógica de coleta, narrativa e abertura de overlays.
# Novos objetos de memória são criados no Editor sem escrever código.

@export var item_type          := ""           # item adicionado ao inventário (vazio = sem item)
@export var narrative_text     := ""           # fala exibida ao coletar
@export var prompt_text        := "[E] Examinar"
@export var has_flashback      := false        # se true, abre flashback_overlay após coletar
@export var flashback_caption  := ""           # texto exibido no flashback
@export var use_photo_overlay  := false        # se true, abre photo_overlay (re-examinável)
@export var overlay_texture:   Texture2D = null
@export var use_diary_overlay  := false        # se true, abre diary_overlay

const INTERACT_RADIUS := 72.0

var _done      := false  # objeto já foi destruído (itens normais)
var _collected := false  # foto: já foi recolhida ao inventário (mas o objeto persiste)

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label    = $PromptLabel


func _ready() -> void:
	add_to_group("memory_item")
	prompt.text    = prompt_text
	prompt.visible = false
	_bob()


func _bob() -> void:
	# Animação de flutuação suave em loop para indicar interatividade
	var tw := create_tween().set_loops()
	tw.tween_property(sprite, "position:y", sprite.position.y - 3.0, 1.1).set_trans(Tween.TRANS_SINE)
	tw.tween_property(sprite, "position:y", sprite.position.y + 3.0, 1.1).set_trans(Tween.TRANS_SINE)


func _process(_d: float) -> void:
	if _done:
		return
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var in_range := global_position.distance_to(player.global_position) < INTERACT_RADIUS
	prompt.visible = in_range
	if in_range and Input.is_action_just_pressed("interact"):
		_collect()


func _collect() -> void:
	# Fotos são re-examinávéis: o objeto NÃO é destruído, só fica semi-transparente
	if use_photo_overlay and overlay_texture != null:
		if not _collected:
			_collected = true
			prompt.visible = false
			_pickup_effects()
			# Armazena a textura no GameGlobal para que o inventário possa reabri-la
			GameGlobal.photo_texture = overlay_texture
			GameGlobal.photo_caption = flashback_caption
			var tw := create_tween()
			tw.tween_property(sprite, "modulate:a", 0.5, 0.5)
		_open_photo_overlay()
		return

	# Todos os outros itens: recolhe uma vez e remove o nó da cena
	_done          = true
	prompt.visible = false
	_pickup_effects()

	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	tw.tween_callback(queue_free)

	var tree := get_tree()
	if use_diary_overlay:
		# Registra no GameGlobal para reabrir pelo inventário
		GameGlobal.has_diary = true
		await tree.create_timer(0.15).timeout
		var dv := (load("res://scenes/diary_overlay.tscn") as PackedScene).instantiate()
		tree.root.add_child(dv)
	elif has_flashback:
		await tree.create_timer(0.15).timeout
		var fb := (load("res://scenes/flashback_overlay.tscn") as PackedScene).instantiate()
		fb.set("caption_text", flashback_caption)
		tree.root.add_child(fb)


func _pickup_effects() -> void:
	# Dispara narrativa e adiciona item ao inventário via sinais do player
	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("show_custom_narrative") and not narrative_text.is_empty():
		gm.show_custom_narrative(narrative_text)
	if item_type != "":
		var player := get_tree().get_first_node_in_group("player")
		if player:
			player.emit_signal("item_picked_up", item_type)


func _open_photo_overlay() -> void:
	# Guard: evita abrir dois overlays de foto ao mesmo tempo
	if get_tree().root.get_node_or_null("PhotoOverlay"):
		return
	var ov := (load("res://scenes/photo_overlay.tscn") as PackedScene).instantiate()
	ov.set("caption_text", flashback_caption)
	ov.set("overlay_texture", overlay_texture)
	get_tree().root.add_child(ov)
