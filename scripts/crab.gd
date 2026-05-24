extends CharacterBody2D

@export var patrol_dist: float = 80.0
@export var speed: float      = 40.0
@export var pause_dur: float  = 1.5

const GRAVITY := 900.0

enum S { RIGHT, LEFT, PAUSE }
var _state   := S.RIGHT
var _start_x : float
var _pause_t : float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_start_x = global_position.x
	if anim: anim.play("walk")


func _physics_process(delta: float) -> void:
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
				_state = S.LEFT if _state == S.PAUSE and global_position.x >= _start_x else S.RIGHT
				if anim: anim.play("walk")
				# fix direction based on position
				_state = S.LEFT if global_position.x > _start_x else S.RIGHT

	move_and_slide()


func _pause() -> void:
	_state = S.PAUSE
	_pause_t = pause_dur
	velocity.x = 0.0
	if anim: anim.play("idle")
