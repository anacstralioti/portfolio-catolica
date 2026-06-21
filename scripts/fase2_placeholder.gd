extends Control

# Placeholder da Fase 2, tela "em breve" mostrada após a cutscene do tsunami.
# Quando qualquer tecla é pressionada, faz fade-out e retorna ao menu principal.

var _can_input := false

func _ready() -> void:
	# Fade-in ao entrar; libera input apenas após o fade completar
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 1.0)
	tw.tween_callback(func() -> void: _can_input = true)

func _input(event: InputEvent) -> void:
	if not _can_input:
		return
	if event.is_pressed() and not event.is_echo():
		_can_input = false
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 1.0)
		tw.tween_callback(func() -> void:
			get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
		)
