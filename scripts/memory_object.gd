extends Node2D

## Objeto de memória — itens coletáveis com narrativa e flashback opcional.
## Uso: adicione Sprite2D e Label(name=PromptLabel) como filhos.

@export var item_type          := ""
@export var narrative_text     := ""
@export var prompt_text        := "[E] Examinar"
@export var has_flashback      := false
@export var flashback_caption  := ""
@export var use_photo_overlay  := false
@export var overlay_texture:   Texture2D = null
@export var use_diary_overlay  := false

const INTERACT_RADIUS := 72.0

var _done := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label    = $PromptLabel


func _ready() -> void:
	add_to_group("memory_item")
	prompt.text    = prompt_text
	prompt.visible = false
	_bob()


func _bob() -> void:
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
	_done          = true
	prompt.visible = false

	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("show_custom_narrative"):
		gm.show_custom_narrative(narrative_text)

	if item_type != "":
		var player := get_tree().get_first_node_in_group("player")
		if player:
			player.emit_signal("item_picked_up", item_type)

	# Fade out imediatamente
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.6)
	tw.tween_callback(queue_free)

	var tree := get_tree()
	if use_diary_overlay:
		await tree.create_timer(0.4).timeout
		var dv := (load("res://scenes/diary_overlay.tscn") as PackedScene).instantiate()
		tree.root.add_child(dv)
	elif use_photo_overlay and overlay_texture != null:
		await tree.create_timer(0.4).timeout
		var ov := (load("res://scenes/photo_overlay.tscn") as PackedScene).instantiate()
		ov.set("caption_text", flashback_caption)
		ov.set("overlay_texture", overlay_texture)
		tree.root.add_child(ov)
	elif has_flashback:
		await tree.create_timer(0.4).timeout
		var fb := (load("res://scenes/flashback_overlay.tscn") as PackedScene).instantiate()
		fb.set("caption_text", flashback_caption)
		tree.root.add_child(fb)
