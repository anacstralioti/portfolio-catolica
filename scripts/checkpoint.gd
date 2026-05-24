extends Area2D

@export var checkpoint_id: int = 1

var _hit := false

@onready var anim: AnimatedSprite2D    = $AnimatedSprite2D
@onready var particles: CPUParticles2D = $Particles
@onready var sfx: AudioStreamPlayer2D  = $SFX


func _ready() -> void:
	body_entered.connect(_on_body)
	if anim: anim.play("idle")


func _on_body(body: Node2D) -> void:
	if _hit or not body.is_in_group("player"): return
	_hit = true
	if anim: anim.play("active")
	if particles: particles.emitting = true
	if sfx: sfx.play()
	if anim:
		var tw := create_tween()
		tw.tween_property(anim, "modulate", Color(0.6, 1.4, 0.8), 0.12)
		tw.tween_property(anim, "modulate", Color.WHITE, 0.35)
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("register_checkpoint"):
		gm.register_checkpoint(checkpoint_id)
