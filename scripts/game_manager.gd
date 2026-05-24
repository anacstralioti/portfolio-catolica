extends Node

## Game Manager - FSM ambiental + save/load
## Fase 1: Ecos do Silêncio

enum State { LIMPO, TRANSICAO, PREPARANDO }

const SAVE_PATH := "user://fase1_save.json"
const NARRATIVAS := {
	"intro"       : "Está tudo tão quieto...",
	"mid"         : "Eu preciso continuar...",
	"checkpoint1" : "Este lugar... parece familiar.",
	"checkpoint2"  : "Quanto tempo passou?",
	"end"         : "Tem algo além do horizonte."
}

var state          := State.LIMPO
var progress       := 0.0
var shells         := 0
var checkpoints    := 0
var _spawn_x       := 80.0

const _CHECKPOINT_X := { 0: 80.0, 1: 700.0, 2: 2200.0, 3: 4500.0 }

signal state_changed(s: int)
signal phase_complete

@onready var music_player: AudioStreamPlayer     = $MusicPlayer
@onready var ambience_player: AudioStreamPlayer  = $AmbiencePlayer
@onready var debris_layer: Node2D                = $World/DebrisLayer
@onready var narrative_ui                        = $UI/NarrativeUI
@onready var hud                                 = $UI/HUD


func _ready() -> void:
	add_to_group("game_manager")
	_load()
	_enter(State.LIMPO)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.shell_collected.connect(_on_shell)
		player.item_picked_up.connect(_on_item_pickup)
		if _spawn_x != 80.0:
			player.global_position.x = _spawn_x


func _process(_d: float) -> void:
	match state:
		State.LIMPO:
			if progress >= 0.4:
				_enter(State.TRANSICAO)
		State.TRANSICAO:
			if progress >= 0.85:
				_enter(State.PREPARANDO)
		State.PREPARANDO:
			if progress >= 1.0:
				_save()
				emit_signal("phase_complete")


func _enter(s: State) -> void:
	state = s
	emit_signal("state_changed", s)
	match s:
		State.LIMPO:
			_show_narrative("intro")
		State.TRANSICAO:
			if debris_layer:
				var tw := create_tween()
				tw.tween_property(debris_layer, "modulate:a", 1.0, 3.0)
			_show_narrative("mid")
		State.PREPARANDO:
			_show_narrative("end")


func update_progress(x: float, map_w: float) -> void:
	progress = clamp(x / map_w, 0.0, 1.0)
	if hud and hud.has_method("update_progress"):
		hud.update_progress(progress)


func register_checkpoint(id: int) -> void:
	if id > checkpoints:
		checkpoints = id
		_spawn_x = _CHECKPOINT_X.get(id, _spawn_x)
		_save()
	var key := "checkpoint%d" % id
	if NARRATIVAS.has(key):
		_show_narrative(key)


func _on_shell(total: int) -> void:
	shells = total
	if hud and hud.has_method("update_shells"):
		hud.update_shells(total)
	if hud and hud.has_method("add_to_inventory"):
		hud.add_to_inventory("shell")


func _on_item_pickup(item_name: String) -> void:
	if hud and hud.has_method("update_item"):
		hud.update_item(item_name)
	if hud and hud.has_method("add_to_inventory"):
		hud.add_to_inventory(item_name)


func _show_narrative(key: String) -> void:
	if narrative_ui and NARRATIVAS.has(key):
		narrative_ui.show_text(NARRATIVAS[key])


# ---- SAVE / LOAD ----

func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"shells": shells,
			"checkpoints": checkpoints,
			"progress": progress,
			"state": state,
			"spawn_x": _spawn_x
		}))
		f.close()


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return
	var j := JSON.new()
	if j.parse(f.get_as_text()) == OK:
		var d: Dictionary = j.get_data()
		shells      = d.get("shells", 0)
		checkpoints = d.get("checkpoints", 0)
		progress    = d.get("progress", 0.0)
		_spawn_x    = d.get("spawn_x", _CHECKPOINT_X.get(checkpoints, 80.0))
	f.close()
