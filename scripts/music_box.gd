extends Node2D

# Caixinha de música, objeto de memória especial.
# Ao interagir, toca uma melodia procedural e abre um flashback após a fala.

@export var narrative_text    := "Ainda toca. Como ela ainda toca?"
@export var flashback_caption := "Um dia de chuva... mamãe tocava e a gente dançava na sala."

const INTERACT_RADIUS := 38.0  # raio menor que MemoryObject porque é objeto delicado/próximo

var _used := false               # impede que o flashback seja aberto mais de uma vez
var _sfx: AudioStreamPlayer      # player de áudio criado por código (sem nó na cena)

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label    = $PromptLabel


func _ready() -> void:
	# Cria o player de áudio em código para não precisar de nó extra na cena
	_sfx = AudioStreamPlayer.new()
	_sfx.volume_db = -4.0
	add_child(_sfx)
	prompt.text    = "[E] Ouvir"
	prompt.visible = false
	_idle_anim()


func _idle_anim() -> void:
	# Bob suave em loop, indica que o objeto é interativo mesmo sem prompt visível
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

	# Toca a melodia gerada proceduralmente (7 notas em Lá menor, timbre de sino)
	_sfx.stream = ProceduralSFX.music_box_melody()
	_sfx.play()

	# Exibe a fala narrativa via GameManager
	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("show_custom_narrative"):
		gm.show_custom_narrative(narrative_text)

	# Aguarda o tempo de leitura da fala antes de abrir o flashback,
	# garantindo que o jogador leia antes da tela mudar.
	# Fórmula: ~45ms por caractere + 4.5s de margem
	var wait := narrative_text.length() * 0.045 + 4.5
	var tree := get_tree()
	await tree.create_timer(wait).timeout
	var fb := (load("res://scenes/flashback_overlay.tscn") as PackedScene).instantiate()
	fb.set("caption_text", flashback_caption)
	tree.root.add_child(fb)
