extends Node2D

## Pipa rasgada — balança no galho e dispara fala ao jogador se aproximar.

@export var narrative_text := "A gente soltava pipa aqui todo verão..."

const NOTIFY_DIST := 60.0

var _notified := false


func _ready() -> void:
	_swing()


func _swing() -> void:
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
