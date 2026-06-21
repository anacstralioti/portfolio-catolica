extends Area2D

# Poça, Area2D que notifica o player ao entrar/sair, reduzindo sua velocidade.
# A lógica de redução de velocidade (PUDDLE_SLOW = 0.45) fica no player.gd.

func _ready() -> void:
	add_to_group("puddle")
	body_entered.connect(func(b): if b.is_in_group("player") and b.has_method("enter_puddle"): b.enter_puddle())
	body_exited.connect(func(b): if b.is_in_group("player") and b.has_method("exit_puddle"): b.exit_puddle())
