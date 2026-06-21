extends Node2D

# Pegadas na areia, pulsam suavemente entre visível e quase invisível em loop.
# São elementos puramente decorativos; a opacidade oscila com Tween SINE.

func _ready() -> void:
	# Opacidade: 80% → 20% → 80% a cada ~3.8s, efeito de "desaparecer e reaparecer"
	var tw := create_tween().set_loops()
	tw.tween_property(self, "modulate:a", 0.20, 3.8).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "modulate:a", 0.80, 3.8).set_trans(Tween.TRANS_SINE)
