extends ParallaxBackground

# Fundo com parallax, a camada do mar (SeaLayer) desloca-se independentemente
# do scroll do ParallaxBackground para criar a ilusão de ondas se movendo.

@onready var sea_layer: ParallaxLayer = $SeaLayer

var _scroll := 0.0
const SEA_SPEED := 6.0  # px/s, velocidade do deslocamento horizontal do mar


func _process(delta: float) -> void:
	if sea_layer:
		# fmod garante que o scroll reseta ao completar 640px (evita overflow de float)
		_scroll = fmod(_scroll + SEA_SPEED * delta, 640.0)
		sea_layer.motion_offset.x = _scroll
