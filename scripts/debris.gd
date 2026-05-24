extends RigidBody2D
# debris.gd

func _ready() -> void:
	gravity_scale = 1.0
	linear_damp   = 3.5
	lock_rotation = true

func _integrate_forces(s: PhysicsDirectBodyState2D) -> void:
	var v := s.linear_velocity
	v.x = clamp(v.x, -110.0, 110.0)
	s.linear_velocity = v
