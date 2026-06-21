extends Area2D

# Zona de gatilho, Area2D invisível que dispara narrativa uma única vez ao ser tocada.
# Configurável via @export no Editor, sem precisar criar um script por zona.

@export var narrative_text := ""

var _triggered := false  # garante disparo único (não re-dispara se o jogador sair e voltar)


func _ready() -> void:
	body_entered.connect(_on_body)


func _on_body(body: Node2D) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	_triggered = true
	# Delay de 0.15s evita sobrepor narrativas que estejam sendo exibidas ao entrar na zona
	await get_tree().create_timer(0.15).timeout
	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("show_custom_narrative"):
		gm.show_custom_narrative(narrative_text)
