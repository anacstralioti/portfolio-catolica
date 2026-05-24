extends Area2D
# puddle.gd

func _ready() -> void:
	body_entered.connect(func(b): if b.is_in_group("player") and b.has_method("enter_puddle"): b.enter_puddle())
	body_exited.connect(func(b): if b.is_in_group("player") and b.has_method("exit_puddle"): b.exit_puddle())
