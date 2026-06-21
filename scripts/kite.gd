extends Node2D

# Pipa, objeto ambiental que dispara uma fala narrativa uma única vez
# quando o jogador se aproxima. Anima em balanço suave em loop.

@export var narrative_text := "A gente soltava pipa aqui todo verão..."

const NOTIFY_DIST := 60.0  # distância (px) para disparar a narrativa

var _notified := false  # garante que a fala toca apenas uma vez


func _ready() -> void:
	_swing()


func _swing() -> void:
	# Oscilação lateral em loop, simula a pipa balançando no vento
	var tw := create_tween().set_loops()
	tw.tween_property(self, "rotation_degrees", -11.0, 1.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "rotation_degrees",  11.0, 1.7).set_trans(Tween.TRANS_SINE)


func _process(_d: float) -> void:
	if _notified:
		return
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	if global_position.distance_to(player.global_position) < NOTIFY_DIST:
		_notified = true
		var gm := get_tree().get_first_node_in_group("game_manager")
		if gm and gm.has_method("show_custom_narrative"):
			gm.show_custom_narrative(narrative_text)
