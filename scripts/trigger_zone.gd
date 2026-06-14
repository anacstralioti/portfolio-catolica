extends Area2D

## Zona de gatilho passiva — dispara narrativa uma única vez ao jogador entrar.

@export var narrative_text := ""

var _triggered := false


func _ready() -> void:
	body_entered.connect(_on_body)


func _on_body(body: Node2D) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	_triggered = true
	# Pequeno delay para não sobrepor outras narrativas em andamento
	await get_tree().create_timer(0.15).timeout
	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("show_custom_narrative"):
		gm.show_custom_narrative(narrative_text)
