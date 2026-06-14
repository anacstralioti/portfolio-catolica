extends CanvasLayer

## Flashback overlay — tela branca com legenda emocional.
## Instancie, defina caption_text e adicione à árvore antes de _ready() rodar.

@export var caption_text := ""

@onready var flash_panel:  Control = $FlashPanel
@onready var caption_lbl:  Label   = $FlashPanel/Caption


func _ready() -> void:
	caption_lbl.text   = caption_text
	flash_panel.modulate.a = 0.0

	var tw := create_tween()
	tw.tween_property(flash_panel, "modulate:a", 1.0, 0.7)
	tw.tween_interval(4.0)
	tw.tween_property(flash_panel, "modulate:a", 0.0, 1.2)
	tw.tween_callback(queue_free)
