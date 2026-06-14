extends Node2D

## Pegadas na areia — pulsam suavemente para sugerir impermanência.

func _ready() -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(self, "modulate:a", 0.20, 3.8).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "modulate:a", 0.80, 3.8).set_trans(Tween.TRANS_SINE)
