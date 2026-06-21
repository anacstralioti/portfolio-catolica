extends Control

# Exibe falas narrativas curtas com efeito typewriter (máquina de escrever).
# Usa uma fila interna para não perder mensagens quando já está exibindo uma.

@onready var lbl: Label = $Label

var _busy  := false              # true enquanto uma fala está sendo exibida
var _queue: Array[String] = []   # fila de falas pendentes
var _tw: Tween                   # tween atual (mantido para poder matar se necessário)


func _ready() -> void:
	modulate.a = 0.0  # começa invisível
	if lbl: lbl.text = ""


# Ponto de entrada público. Se já estiver exibindo algo, enfileira a mensagem.
# interrupt = true força a substituição imediata da fala atual.
func show_text(text: String, dur: float = 2.0, interrupt: bool = false) -> void:
	if _busy and not interrupt:
		_queue.append(text)
		return
	_display(text, dur)


func _display(text: String, dur: float) -> void:
	_busy = true
	if lbl:
		lbl.text = text
		lbl.visible_ratio = 0.0  # oculta o texto para o typewriter começar do zero

	if _tw: _tw.kill()  # cancela tween anterior se interrupt=true

	_tw = create_tween()
	# 1. Fade-in rápido (0.1s)
	_tw.tween_property(self, "modulate:a", 1.0, 0.1)
	# 2. Typewriter: cada caractere leva ~18ms
	_tw.tween_property(lbl, "visible_ratio", 1.0, text.length() * 0.018)
	# 3. Pausa para o jogador ler
	_tw.tween_interval(dur)
	# 4. Fade-out suave (0.4s)
	_tw.tween_property(self, "modulate:a", 0.0, 0.4)
	_tw.tween_callback(_done)


func _done() -> void:
	_busy = false
	if lbl: lbl.text = ""
	# Se houver mensagens na fila, exibe a próxima automaticamente
	if _queue.size() > 0:
		_display(_queue.pop_front(), 3.0)
