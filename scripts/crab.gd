extends CharacterBody2D

# Caranguejo, patrulha uma distância fixa em torno da posição inicial.
# Não bloqueia o jogador (collision_layer = 2), mas mantém física no chão.

@export var patrol_dist: float = 80.0  # distância máxima de cada lado do ponto inicial
@export var speed: float      = 40.0   # velocidade de caminhada
@export var pause_dur: float  = 1.5    # tempo parado ao virar de direção

const GRAVITY := 900.0

# FSM simples de 3 estados para o patrulhamento
enum S { RIGHT, LEFT, PAUSE }
var _state   := S.RIGHT
var _start_x : float         # posição X inicial (ponto central da patrulha)
var _pause_t : float = 0.0   # temporizador da pausa

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("crab")
	# Layer 2: caranguejo anda no chão (mask=1), mas não colide com o player (layer≠1)
	collision_layer = 2
	collision_mask  = 1
	_start_x = global_position.x
	if anim: anim.play("walk")


func _physics_process(delta: float) -> void:
	# Gravidade simples, caranguejo fica colado ao chão
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	match _state:
		S.RIGHT:
			velocity.x = speed
			if anim: anim.flip_h = false
			if global_position.x >= _start_x + patrol_dist:
				_pause()
		S.LEFT:
			velocity.x = -speed
			if anim: anim.flip_h = true
			if global_position.x <= _start_x - patrol_dist:
				_pause()
		S.PAUSE:
			velocity.x = 0.0
			_pause_t -= delta
			if _pause_t <= 0.0:
				# Determina direção de retorno pela posição atual vs. ponto inicial
				_state = S.LEFT if global_position.x > _start_x else S.RIGHT
				if anim: anim.play("walk")

	move_and_slide()


func _pause() -> void:
	_state = S.PAUSE
	_pause_t = pause_dur
	velocity.x = 0.0
	if anim: anim.play("idle")
