extends Control

@onready var phase_number_label: Label = $PhaseNumber
@onready var phase_name_label: Label   = $PhaseName

func _ready() -> void:
	phase_number_label.text = "Capítulo %d" % GameGlobal.next_phase_number
	phase_name_label.text   = GameGlobal.next_phase_name

	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 1.5)
	tw.tween_interval(3.0)
	tw.tween_property(self, "modulate:a", 0.0, 1.5)
	tw.tween_callback(_transition)

func _transition() -> void:
	match GameGlobal.next_phase_number:
		1:
			get_tree().change_scene_to_file("res://scenes/fase1_ecos_silencio.tscn")
		2:
			get_tree().change_scene_to_file("res://scenes/fase2_ruinas_oceano.tscn")
		_:
			get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
