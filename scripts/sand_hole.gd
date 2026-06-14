extends StaticBody2D

## Detection radius in world units — player triggers prompt when within this distance
const DETECT_RADIUS := 80.0

@onready var spr: Sprite2D            = $Sprite2D
@onready var col: CollisionShape2D    = $Collision
@onready var prompt: Label            = $Prompt
@onready var sfx: AudioStreamPlayer2D = $SFX

var _filled := false
var _player: Node2D = null
var _connected := false


func _ready() -> void:
	add_to_group("sandhole")
	if prompt: prompt.visible = false


func _physics_process(_d: float) -> void:
	if _filled: return

	if not _player:
		_player = get_tree().get_first_node_in_group("player")
	if not _player: return

	var close := global_position.distance_to(_player.global_position) < DETECT_RADIUS

	if close:
		_show_prompt(_player)
		if not _connected:
			_connected = true
			_player.interact_pressed.connect(_try_fill)
	else:
		_hide_prompt()
		if _connected:
			_connected = false
			if _player.interact_pressed.is_connected(_try_fill):
				_player.interact_pressed.disconnect(_try_fill)


func _show_prompt(body: Node2D) -> void:
	if not prompt: return
	prompt.visible = true
	var active: String = body.get_active_item()
	if active == "shovel":
		prompt.text    = "[E] Tapar buraco"
		prompt.modulate = Color.WHITE
	elif body.has_shovel:
		prompt.text    = "Equipe a pá!"
		prompt.modulate = Color(1.0, 0.85, 0.3, 1.0)
	else:
		prompt.text    = "Precisa de uma pá"
		prompt.modulate = Color(1.0, 0.5, 0.3, 1.0)


func _hide_prompt() -> void:
	if prompt: prompt.visible = false


func _try_fill() -> void:
	if _filled or not _player: return
	if _player.get_active_item() != "shovel": return
	fill()


func fill() -> void:
	_filled = true
	_hide_prompt()
	if _connected and _player and _player.interact_pressed.is_connected(_try_fill):
		_player.interact_pressed.disconnect(_try_fill)
	if sfx: sfx.play()
	var tw := create_tween()
	tw.tween_property(spr, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): if col: col.disabled = true)
