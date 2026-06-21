extends Area2D

# Checkpoint, ponto de salvamento automático.
# Quando Ichigo toca na área, registra o progresso no GameManager (que grava em JSON).
# Após ativado (_hit = true), ignora colisões futuras.

@export var checkpoint_id: int = 1  # ID sequencial (1, 2, 3…) usado pelo GameManager

var _hit := false  # garante que o save ocorra apenas uma vez por checkpoint

@onready var anim:      AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: CPUParticles2D   = $Particles
@onready var sfx:       AudioStreamPlayer2D = $SFX


func _ready() -> void:
	body_entered.connect(_on_body)
	if anim: anim.play("idle")
	if sfx: sfx.stream = ProceduralSFX.checkpoint_ping()  # jingle Dó5→Mi5


func _on_body(body: Node2D) -> void:
	if _hit or not body.is_in_group("player"): return
	_hit = true

	# Feedback visual: animação ativa + flash verde + partículas
	if anim: anim.play("active")
	if particles: particles.emitting = true
	if sfx: sfx.play()
	if anim:
		var tw := create_tween()
		tw.tween_property(anim, "modulate", Color(0.6, 1.4, 0.8), 0.12)
		tw.tween_property(anim, "modulate", Color.WHITE,           0.35)

	# Notifica o GameManager para salvar o progresso
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("register_checkpoint"):
		gm.register_checkpoint(checkpoint_id)
