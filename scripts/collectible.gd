extends Area2D

@export var item_type: String = "shell"
@export var bob_amplitude: float = 3.0
@export var bob_speed: float = 2.5

@onready var spr: Sprite2D              = $Sprite2D
@onready var glow: Sprite2D             = $Glow
@onready var particles: CPUParticles2D  = $Particles
@onready var sfx: AudioStreamPlayer2D  = $SFX

var _base_y: float
var _t: float = 0.0
var _done: bool = false


func _ready() -> void:
	add_to_group("collectible")
	set_meta("item_type", item_type)
	_base_y = position.y


func _process(delta: float) -> void:
	if _done: return
	_t += delta
	position.y = _base_y + sin(_t * bob_speed) * bob_amplitude
	if glow:
		glow.modulate.a = 0.15 + sin(_t * 4.0) * 0.08


func collect() -> void:
	if _done: return
	_done = true
	set_deferred("monitoring", false)
	if sfx: sfx.play()
	if particles: particles.emitting = true
	var tw := create_tween().set_parallel(true)
	tw.tween_property(spr, "scale", Vector2(1.6, 1.6), 0.1)
	tw.tween_property(spr, "modulate:a", 0.0, 0.25)
	if glow:
		tw.tween_property(glow, "scale", Vector2(3.0, 3.0), 0.3)
		tw.tween_property(glow, "modulate:a", 0.0, 0.3)
	tw.chain().tween_callback(queue_free)
