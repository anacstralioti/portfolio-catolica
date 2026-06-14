extends Node2D

## Castelo de areia — precisa do balde selecionado para ativar memória.

@export var narrative_text    := "Construímos isso juntos... levou a tarde toda."
@export var flashback_caption := "Ichigo, as torres têm que ser mais altas!\n— Papai ria enquanto empilhava areia com as mãos grandes."

const INTERACT_RADIUS := 80.0

var _used := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label    = $PromptLabel


func _ready() -> void:
	add_to_group("memory_item")
	prompt.visible = false


func _process(_d: float) -> void:
	if _used:
		return
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var in_range := global_position.distance_to(player.global_position) < INTERACT_RADIUS
	prompt.visible = in_range
	if in_range:
		var active: String = player.get_active_item()
		if active == "bucket":
			prompt.text    = "[E] Encher o fosso"
			prompt.modulate = Color.WHITE
		elif player.has_bucket:
			prompt.text    = "Equipe o balde!"
			prompt.modulate = Color(1.0, 0.85, 0.3, 1.0)
		else:
			prompt.text    = "Falta água..."
			prompt.modulate = Color(0.75, 0.75, 0.75, 0.7)
		if Input.is_action_just_pressed("interact") and active == "bucket":
			_use()


func _use() -> void:
	_used          = true
	prompt.visible = false

	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("show_custom_narrative"):
		gm.show_custom_narrative(narrative_text)

	# Pulse visual no castelo
	var tw := create_tween()
	tw.tween_property(sprite, "scale", sprite.scale * 1.18, 0.12)
	tw.tween_property(sprite, "scale", sprite.scale,        0.25)

	var wait := 2.8
	var tree := get_tree()
	await tree.create_timer(wait).timeout
	var fb := (load("res://scenes/flashback_overlay.tscn") as PackedScene).instantiate()
	fb.set("caption_text", flashback_caption)
	tree.root.add_child(fb)
