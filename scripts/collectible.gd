extends Area2D

# Item coletável genérico, como conchas, pá, balde, etc.
# O jogador coleta automaticamente ao entrar na área (CollectArea do player).
# Após coletado, toca SFX, explode em partículas e se remove da cena.

@export var item_type: String  = "shell"  # tipo do item, lido pelo player ao colidir
@export var bob_amplitude: float = 3.0   # altura do movimento de flutuar (px)
@export var bob_speed:     float = 2.5   # frequência do bob (radianos/s)

@onready var spr:       Sprite2D       = $Sprite2D
@onready var glow:      Sprite2D       = $Glow
@onready var particles: CPUParticles2D = $Particles
@onready var sfx:       AudioStreamPlayer2D = $SFX

var _base_y: float       # posição Y original, o bob oscila em relação a ela
var _t:      float = 0.0 # tempo acumulado para o cálculo do seno
var _done:   bool  = false  # evita dupla coleta caso duas áreas colidam no mesmo frame


func _ready() -> void:
	add_to_group("collectible")
	set_meta("item_type", item_type)  # player lê o tipo via get_meta("item_type")
	_base_y = position.y
	if sfx:
		sfx.stream = ProceduralSFX.item_pickup()  # pré-carrega o SFX procedural


func _process(delta: float) -> void:
	if _done: return
	_t += delta
	# Bob: oscilação vertical suave usando seno
	position.y = _base_y + sin(_t * bob_speed) * bob_amplitude
	# Glow pulsa com frequência maior que o bob, criando efeito de "respiração"
	if glow:
		glow.modulate.a = 0.15 + sin(_t * 4.0) * 0.08


# Chamado pelo player._on_collect_area_entered() quando a área de coleta toca este item.
func collect() -> void:
	if _done: return
	_done = true
	set_deferred("monitoring", false)  # desativa colisão sem erro de física mid-frame

	if sfx:
		sfx.pitch_scale = randf_range(0.95, 1.08)  # variação sutil de pitch a cada coleta
		sfx.play()
	if particles: particles.emitting = true

	# Animação de coleta: escala, desvanece e se remove
	var tw := create_tween().set_parallel(true)
	tw.tween_property(spr,  "scale",      Vector2(1.6, 1.6), 0.1)
	tw.tween_property(spr,  "modulate:a", 0.0,               0.25)
	if glow:
		tw.tween_property(glow, "scale",      Vector2(3.0, 3.0), 0.3)
		tw.tween_property(glow, "modulate:a", 0.0,               0.3)
	tw.chain().tween_callback(queue_free)
