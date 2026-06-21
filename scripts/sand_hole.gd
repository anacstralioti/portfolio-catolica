extends StaticBody2D

# Buraco de areia, obstáculo que bloqueia o caminho de Ichigo.
# Só pode ser preenchido se o jogador tiver a pá equipada no slot ativo.
# Usa conexão dinâmica de sinal para evitar que interact_pressed dispare em objetos distantes.

const DETECT_RADIUS := 80.0  # distância (px) em que o prompt aparece e o sinal é conectado

@onready var spr:    Sprite2D            = $Sprite2D
@onready var col:    CollisionShape2D    = $Collision
@onready var prompt: Label               = $Prompt
@onready var sfx:    AudioStreamPlayer2D = $SFX

var _filled    := false   # após preenchido, o buraco não bloqueia mais
var _player:     Node2D = null
var _connected := false   # controla se o sinal interact_pressed está conectado


func _ready() -> void:
	add_to_group("sandhole")
	if prompt: prompt.visible = false
	if sfx: sfx.stream = ProceduralSFX.sand_fill()


func _physics_process(_d: float) -> void:
	if _filled: return

	# Busca o player uma única vez (evita get_first_node_in_group todo frame)
	if not _player:
		_player = get_tree().get_first_node_in_group("player")
	if not _player: return

	var close := global_position.distance_to(_player.global_position) < DETECT_RADIUS

	if close:
		_show_prompt(_player)
		# Conecta o sinal apenas quando próximo, desconecta ao se afastar.
		# Isso evita que pressionar E em um buraco distante dispare _try_fill.
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
	# O prompt muda conforme o estado do inventário, orientando o jogador
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
	# Verifica novamente o item ativo no momento do pressionar E
	if _player.get_active_item() != "shovel": return
	fill()


func fill() -> void:
	_filled = true
	_hide_prompt()
	if _connected and _player and _player.interact_pressed.is_connected(_try_fill):
		_player.interact_pressed.disconnect(_try_fill)

	if sfx: sfx.play()

	# Animação de preenchimento: desvanece o sprite e desativa a colisão
	var tw := create_tween()
	tw.tween_property(spr, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): if col: col.disabled = true)
