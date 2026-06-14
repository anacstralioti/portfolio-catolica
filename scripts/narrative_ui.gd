extends Control

@onready var lbl: Label = $Label
var _busy := false
var _queue: Array[String] = []
var _tw: Tween


func _ready() -> void:
	modulate.a = 0.0
	if lbl: lbl.text = ""


func show_text(text: String, dur: float = 2.5, interrupt: bool = false) -> void:
	if _busy and not interrupt:
		_queue.append(text)
		return
	_display(text, dur)


func _display(text: String, dur: float) -> void:
	_busy = true
	if lbl:
		lbl.text = text
		lbl.visible_ratio = 0.0
	if _tw: _tw.kill()
	_tw = create_tween()
	_tw.tween_property(self, "modulate:a", 1.0, 0.3)
	_tw.tween_property(lbl, "visible_ratio", 1.0, text.length() * 0.035)
	_tw.tween_interval(dur)
	_tw.tween_property(self, "modulate:a", 0.0, 0.5)
	_tw.tween_callback(_done)


func _done() -> void:
	_busy = false
	if lbl: lbl.text = ""
	if _queue.size() > 0:
		_display(_queue.pop_front(), 4.0)
