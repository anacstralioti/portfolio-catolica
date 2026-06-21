extends CharacterBody2D

# Controlador de Ichigo, física, movimentação, coleta de itens e sinais.
# É o centro da interação: emite sinais que o GameManager e os objetos escutam.

# ── Constantes físicas ────────────────────────────────────────────────────────
const GRAVITY      := 980.0   # px/s², acelera a queda
const WALK_SPEED   := 90.0    # px/s
const RUN_SPEED    := 160.0   # px/s (Shift pressionado)
const JUMP_VEL     := -320.0  # px/s negativo = para cima
const PUDDLE_SLOW  := 0.45    # multiplicador de velocidade em poças

# Itens que mostram o sprite "na mão" de Ichigo ao serem equipados
const HOLDABLE_ITEMS := ["shovel", "bucket"]

# Caminhos das texturas dos itens seguráveis
const ITEM_TEXTURES := {
	"shovel": "res://sprites/items/shovel.svg",
	"bucket": "res://sprites/items/bucket.svg",
}

# ── Estado do jogador ─────────────────────────────────────────────────────────
var in_puddle    := false       # verdadeiro enquanto dentro de uma Area2D de poça
var has_shovel   := false       # controla prompt do sand_hole ("Equipe a pá!")
var has_bucket   := false       # controla prompt do sand_castle
var shell_count  := 0
var _facing_right := true
var _gm: Node = null            # cache do GameManager (evita busca todo frame)
var _disabled    := false       # true após fim da fase, Ichigo anda automaticamente
var _last_active_item := ""     # detecta troca de item para atualizar visual

# ── Sistema de passos na areia ────────────────────────────────────────────────
var _step_t        := 0.0       # temporizador entre passos
var _step_idx      := 0         # índice circular entre as 4 variações de som
var _step_variants := []        # 4 AudioStreamWAV pré-gerados no _ready
var _sfx_step: AudioStreamPlayer2D

# ── Sinais ────────────────────────────────────────────────────────────────────
# Emitidos para o GameManager e para os objetos interativos do mundo
signal shell_collected(total: int)
signal item_picked_up(item_name: String)
signal interact_pressed   # emitido a cada pressão de E/Z, objetos próximos escutam

@onready var anim:         AnimatedSprite2D = $AnimatedSprite2D
@onready var dust:         CPUParticles2D   = $Dust
@onready var interact_area: Area2D          = $InteractArea
@onready var collect_area:  Area2D          = $CollectArea
@onready var held_sprite:   Sprite2D        = $HeldItemSprite


func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask  = 1  # colide com geometria estática; NÃO com caranguejos (layer 2)
	collect_area.area_entered.connect(_on_collect_area_entered)
	call_deferred("_attach_camera")  # deferred para garantir que a câmera já existe na árvore
	_setup_footstep_sfx()


func _setup_footstep_sfx() -> void:
	_sfx_step             = AudioStreamPlayer2D.new()
	_sfx_step.volume_db   = -4.0
	_sfx_step.max_distance = 300.0
	add_child(_sfx_step)
	# Pré-gera 4 variações do passo, footstep_sand usa seed aleatória, então são diferentes
	for _i in 4:
		_step_variants.append(ProceduralSFX.footstep_sand())


func _attach_camera() -> void:
	# Reparenta a câmera da cena para ser filha de Ichigo sem mover a câmera no mundo
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam.reparent(self, false)


# Chamado pelo GameManager ao término da fase, Ichigo caminha sozinha para a direita
func disable() -> void:
	_disabled = true
	_facing_right = true
	anim.flip_h = false
	velocity.x = RUN_SPEED


func _physics_process(delta: float) -> void:
	# Modo cinemático: apenas gravidade + movimento para a direita
	if _disabled:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0
		move_and_slide()
		_update_anim()
		_update_footstep(delta)
		return

	# ── Gravidade ─────────────────────────────────────────────────────────────
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if velocity.y > 0:
			velocity.y = 0

	# ── Movimento horizontal ──────────────────────────────────────────────────
	var dir := 0.0
	if Input.is_action_pressed("move_right"):
		dir = 1.0
	elif Input.is_action_pressed("move_left"):
		dir = -1.0

	var spd := RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
	if in_puddle:
		spd *= PUDDLE_SLOW  # poça reduz velocidade a 45%

	if dir != 0.0:
		velocity.x = dir * spd
		_facing_right = dir > 0.0
		anim.flip_h = not _facing_right
	else:
		# Desacelera suavemente ao soltar a tecla (evita parada brusca)
		velocity.x = move_toward(velocity.x, 0.0, spd * 3.0 * delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VEL

	if Input.is_action_just_pressed("interact"):
		emit_signal("interact_pressed")         # objetos próximos reagem
		_try_open_inventory_item()              # tenta abrir foto/carta pelo inventário

	move_and_slide()

	# Atualiza o progresso narrativo no GameManager com a posição X atual
	if not _gm:
		_gm = get_tree().get_first_node_in_group("game_manager")
	if _gm:
		_gm.update_progress(global_position.x, 6400.0)

	_update_anim()
	_update_footstep(delta)


func _update_anim() -> void:
	# Detecta troca de item ativo para atualizar sprite na mão
	var active := get_active_item()
	if active != _last_active_item:
		_last_active_item = active
		_set_held_visual(active)

	# Prioridade de animações: ar > agachado > segurando > movendo > parado
	var next: String
	if not is_on_floor():
		next = "fall" if velocity.y > 0.0 else "jump"
	elif Input.is_action_pressed("move_down"):
		next = "crouch"
	elif active in HOLDABLE_ITEMS:
		next = "hold"
	elif abs(velocity.x) > 5.0:
		next = "run" if Input.is_action_pressed("run") else "walk"
	else:
		next = "idle"

	if anim.animation != next:
		anim.play(next)

	# Bob da cabeça: oscilação vertical proporcional à velocidade horizontal
	var spd_ratio: float = clamp(abs(velocity.x) / RUN_SPEED, 0.0, 1.0)
	var bob: float = sin(Time.get_ticks_msec() * 0.018) * 0.6 * spd_ratio if is_on_floor() else 0.0
	anim.position.y = -19.0 + bob

	# Poeira aparece ao correr no chão
	dust.emitting = is_on_floor() and abs(velocity.x) > 20.0

	# Espelha o item segurado junto com o personagem
	if held_sprite.visible:
		held_sprite.flip_h = not _facing_right
		held_sprite.position.x = 8.0 if _facing_right else -8.0


func _set_held_visual(item: String) -> void:
	if item == "" or not ITEM_TEXTURES.has(item):
		held_sprite.visible = false
		return
	held_sprite.texture = load(ITEM_TEXTURES[item])
	held_sprite.visible = true


func _on_collect_area_entered(area: Area2D) -> void:
	if not area.is_in_group("collectible"):
		return
	var type: String = area.get_meta("item_type", "")
	match type:
		"shell":
			shell_count += 1
			emit_signal("shell_collected", shell_count)
		"shovel":
			has_shovel = true
			emit_signal("item_picked_up", "shovel")
		"bucket":
			has_bucket = true
			emit_signal("item_picked_up", "bucket")
	area.collect()  # aciona a animação de coleta no collectible


# Lê o item ativo do HUD, usa has_method para não criar dependência direta
func get_active_item() -> String:
	var hud_node := get_tree().get_first_node_in_group("hud")
	if hud_node and hud_node.has_method("get_active_item"):
		return hud_node.get_active_item()
	return ""


# Tenta abrir foto ou carta a partir do inventário ao pressionar E
func _try_open_inventory_item() -> void:
	var active := get_active_item()
	match active:
		"photo":
			if GameGlobal.photo_texture == null: return
			# Guard: evita abrir dois overlays de foto simultaneamente
			if get_tree().root.get_node_or_null("PhotoOverlay"): return
			var ov := (load("res://scenes/photo_overlay.tscn") as PackedScene).instantiate()
			ov.name = "PhotoOverlay"
			ov.set("caption_text", GameGlobal.photo_caption)
			ov.set("overlay_texture", GameGlobal.photo_texture)
			get_tree().root.add_child(ov)
		"diary":
			if not GameGlobal.has_diary: return
			if get_tree().root.get_node_or_null("DiaryOverlay"): return
			var dv := (load("res://scenes/diary_overlay.tscn") as PackedScene).instantiate()
			dv.name = "DiaryOverlay"
			get_tree().root.add_child(dv)


func enter_puddle() -> void:
	in_puddle = true

func exit_puddle() -> void:
	in_puddle = false


func _update_footstep(delta: float) -> void:
	# Só toca passo se estiver no chão e se movendo
	if not is_on_floor() or abs(velocity.x) < 5.0:
		_step_t = 0.0
		return
	# Intervalo varia com velocidade e terreno (poça é mais lenta)
	var interval := 0.20 if Input.is_action_pressed("run") else 0.34
	if in_puddle:
		interval *= 1.4
	_step_t += delta
	if _step_t >= interval:
		_step_t = 0.0
		_play_step()


func _play_step() -> void:
	if not _sfx_step or _step_variants.is_empty():
		return
	_sfx_step.stream      = _step_variants[_step_idx]
	_sfx_step.pitch_scale = randf_range(0.90, 1.10)  # micro-variação de pitch evita repetição perceptível
	_sfx_step.play()
	# Cicla entre as 4 variações pré-geradas para evitar repetição
	_step_idx = (_step_idx + 1) % _step_variants.size()
