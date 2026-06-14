extends Node2D

## Gaivota — fica parada até o jogador se aproximar, depois voa para longe.

const NOTICE_DIST := 72.0
const FLY_SPEED   := 58.0

var _flying  := false
var _fly_dir := Vector2(0.7, -1.0).normalized()

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_idle_bob()


func _idle_bob() -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(sprite, "position:y", -2.0, 1.4).set_trans(Tween.TRANS_SINE)
	tw.tween_property(sprite, "position:y",  2.0, 1.4).set_trans(Tween.TRANS_SINE)


func _process(delta: float) -> void:
	if _flying:
		position    += _fly_dir * FLY_SPEED * delta
		sprite.flip_h = _fly_dir.x < 0
		# Remove quando sair completamente da tela
		if position.y < -80 or position.x < -100 or position.x > 6600:
			queue_free()
		return

	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	if global_position.distance_to(player.global_position) < NOTICE_DIST:
		_fly_away(player)


func _fly_away(player: Node2D) -> void:
	_flying = true
	# Voa na direção oposta ao jogador, sempre subindo
	var away  := (global_position - player.global_position).normalized()
	_fly_dir  = Vector2(away.x * 0.5 + sign(away.x) * 0.3, -1.0).normalized()
