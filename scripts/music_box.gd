extends Node2D

## Caixinha de música — interagir dispara narrativa e depois um flashback.

@export var narrative_text    := "Ainda toca. Como ela ainda toca?"
@export var flashback_caption := "Um dia de chuva... mamãe tocava e a gente dançava na sala."

const INTERACT_RADIUS := 38.0

var _used := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label    = $PromptLabel


func _ready() -> void:
	prompt.text    = "[E] Ouvir"
	prompt.visible = false
	_idle_anim()


func _idle_anim() -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(sprite, "position:y", -2.0, 2.0).set_trans(Tween.TRANS_SINE)
	tw.tween_property(sprite, "position:y",  2.0, 2.0).set_trans(Tween.TRANS_SINE)


func _process(_d: float) -> void:
	if _used:
		return
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var in_range := global_position.distance_to(player.global_position) < INTERACT_RADIUS
	prompt.visible = in_range
	if in_range and Input.is_action_just_pressed("interact"):
		_use()


func _use() -> void:
	_used          = true
	prompt.visible = false

	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("show_custom_narrative"):
		gm.show_custom_narrative(narrative_text)

	# Aguarda a narrativa terminar antes do flashback
	var wait := narrative_text.length() * 0.045 + 4.5
	var tree := get_tree()
	await tree.create_timer(wait).timeout
	var fb := (load("res://scenes/flashback_overlay.tscn") as PackedScene).instantiate()
	fb.set("caption_text", flashback_caption)
	tree.root.add_child(fb)
