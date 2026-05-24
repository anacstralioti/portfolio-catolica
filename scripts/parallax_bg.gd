extends ParallaxBackground

@onready var sea_layer: ParallaxLayer = $SeaLayer

var _scroll := 0.0
const SEA_SPEED := 6.0


func _process(delta: float) -> void:
	if sea_layer:
		_scroll = fmod(_scroll + SEA_SPEED * delta, 640.0)
		sea_layer.motion_offset.x = _scroll
