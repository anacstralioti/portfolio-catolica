extends RigidBody2D

# Detrito, objeto de física simples que reage a colisões.
# Fica visível nos estados LEMBRANCA e CONFRONTO (controlado pelo GameManager via modulate).
# linear_damp alto (3.5) faz o objeto parar rapidamente ao tocar o chão.

func _ready() -> void:
	gravity_scale = 1.0
	linear_damp   = 3.5   # amortecimento forte, o objeto não desliza indefinidamente
	lock_rotation = true  # sem rotação: mantém visual alinhado mesmo após colisão

func _integrate_forces(s: PhysicsDirectBodyState2D) -> void:
	# Limita velocidade horizontal para evitar que detritos "voem" ao ser empurrados
	var v := s.linear_velocity
	v.x = clamp(v.x, -110.0, 110.0)
	s.linear_velocity = v
