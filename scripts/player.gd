extends CharacterBody2D

## Ichigo - Player Controller
## Fase 1: Ecos do Silêncio

const GRAVITY      := 980.0
const WALK_SPEED   := 90.0
const RUN_SPEED    := 160.0
const JUMP_VEL     := -320.0
const PUDDLE_SLOW  := 0.45

var in_puddle    := false
var has_shovel   := false
var has_bucket   := false
var shell_count  := 0
var held_item    := ""
var _facing_right := true
var _gm: Node = null

signal shell_collected(total: int)
signal item_picked_up(item_name: String)
signal interact_pressed

@onready var anim: AnimatedSprite2D       = $AnimatedSprite2D
@onready var dust: CPUParticles2D         = $Dust
@onready var interact_area: Area2D        = $InteractArea
@onready var collect_area: Area2D         = $CollectArea


func _ready() -> void:
	add_to_group("player")
	collect_area.area_entered.connect(_on_collect_area_entered)
	call_deferred("_attach_camera")


func _attach_camera() -> void:
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam.reparent(self, false)


func _physics_process(delta: float) -> void:
	# ---- gravity ----
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if velocity.y > 0:
			velocity.y = 0

	# ---- horizontal movement ----
	var dir := 0.0
	if Input.is_action_pressed("move_right"):
		dir = 1.0
	elif Input.is_action_pressed("move_left"):
		dir = -1.0

	var spd := RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
	if in_puddle:
		spd *= PUDDLE_SLOW

	if dir != 0.0:
		velocity.x = dir * spd
		_facing_right = dir > 0.0
		anim.flip_h = not _facing_right
	else:
		velocity.x = move_toward(velocity.x, 0.0, spd * 3.0 * delta)

	# ---- jump ----
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VEL

	# ---- crouch ----
	# (visual only – held anim if down pressed)

	# ---- interact ----
	if Input.is_action_just_pressed("interact"):
		emit_signal("interact_pressed")

	move_and_slide()
	if not _gm:
		_gm = get_tree().get_first_node_in_group("game_manager")
	if _gm:
		_gm.update_progress(global_position.x, 6400.0)
	_update_anim()


func _update_anim() -> void:
	var next: String
	if not is_on_floor():
		next = "jump"
	elif Input.is_action_pressed("move_down"):
		next = "crouch"
	elif abs(velocity.x) > 5.0:
		next = "run" if Input.is_action_pressed("run") else "walk"
	else:
		next = "idle"

	if anim.animation != next:
		anim.play(next)

	# gentle vertical bob while walking/running to add life
	var spd_ratio: float = clamp(abs(velocity.x) / RUN_SPEED, 0.0, 1.0)
	var bob: float = sin(Time.get_ticks_msec() * 0.018) * 0.6 * spd_ratio if is_on_floor() else 0.0
	anim.position.y = -19.0 + bob

	dust.emitting = is_on_floor() and abs(velocity.x) > 20.0


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
			held_item = "shovel"
			emit_signal("item_picked_up", "shovel")
		"bucket":
			has_bucket = true
			held_item = "bucket"
			emit_signal("item_picked_up", "bucket")
	area.collect()


func get_active_item() -> String:
	var hud_node := get_tree().get_first_node_in_group("hud")
	if hud_node and hud_node.has_method("get_active_item"):
		return hud_node.get_active_item()
	return held_item


func enter_puddle() -> void:
	in_puddle = true

func exit_puddle() -> void:
	in_puddle = false
