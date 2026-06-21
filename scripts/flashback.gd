extends CanvasLayer

# Overlay de flashback, tela branca que fade-in, mostra uma legenda por 4s e some.
# Instanciado dinamicamente por memory_object.gd, sand_castle.gd e music_box.gd.
# Após o fade-out, remove-se automaticamente da árvore (queue_free).

@export var caption_text := ""

@onready var flash_panel:  Control = $FlashPanel
@onready var caption_lbl:  Label   = $FlashPanel/Caption


func _ready() -> void:
	caption_lbl.text       = caption_text
	flash_panel.modulate.a = 0.0

	# Sequência: fade-in (0.7s) → exibe por 4s → fade-out (1.2s) → destrói
	var tw := create_tween()
	tw.tween_property(flash_panel, "modulate:a", 1.0, 0.7)
	tw.tween_interval(4.0)
	tw.tween_property(flash_panel, "modulate:a", 0.0, 1.2)
	tw.tween_callback(queue_free)
