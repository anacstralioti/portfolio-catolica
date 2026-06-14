extends Control

const ITEM_TEXTURES: Dictionary = {
	"shell":    preload("res://sprites/items/shell_a.svg"),
	"shovel":   preload("res://sprites/items/shovel.svg"),
	"bucket":   preload("res://sprites/items/bucket.svg"),
	"photo":    preload("res://sprites/items/photo.svg"),
	"diary":    preload("res://sprites/items/diary.svg"),
	"necklace": preload("res://sprites/items/necklace.svg"),
}

@onready var prog_bar: ProgressBar = $ProgressFill
@onready var flash: ColorRect       = $Flash

var _inventory: Dictionary = {}
var _inv_order: Array      = []
var _slot_icons: Array     = []
var _slot_labels: Array    = []
var _slot_styles: Array    = []
var _active_slot: int      = -1


func _ready() -> void:
	add_to_group("hud")
	if flash:
		flash.modulate.a = 0.0
	_build_inv_bar()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key: int = event.keycode
		if key >= KEY_1 and key <= KEY_8:
			_select_slot(key - KEY_1)


func _build_inv_bar() -> void:
	const SLOT_COUNT = 8
	const SLOT_SIZE  = 22
	const SLOT_GAP   = 2
	const PAD        = 3
	const BAR_W      = SLOT_COUNT * SLOT_SIZE + (SLOT_COUNT - 1) * SLOT_GAP + PAD * 2
	const BAR_H      = SLOT_SIZE + PAD * 2
	const BOT_MARGIN = 5

	var bar := Control.new()
	bar.name          = "InventoryBar"
	bar.anchor_left   = 0.5
	bar.anchor_right  = 0.5
	bar.anchor_top    = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_left   = -BAR_W / 2.0
	bar.offset_right  =  BAR_W / 2.0
	bar.offset_top    = -(BAR_H + BOT_MARGIN)
	bar.offset_bottom = -BOT_MARGIN
	add_child(bar)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.55)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bar.add_child(bg)

	for i in SLOT_COUNT:
		var style := StyleBoxFlat.new()
		style.bg_color            = Color(0.08, 0.08, 0.08, 0.80)
		style.border_color        = Color(0.45, 0.45, 0.45, 1.0)
		style.border_width_left   = 1
		style.border_width_right  = 1
		style.border_width_top    = 1
		style.border_width_bottom = 1
		style.corner_radius_top_left     = 2
		style.corner_radius_top_right    = 2
		style.corner_radius_bottom_left  = 2
		style.corner_radius_bottom_right = 2

		var slot := Panel.new()
		slot.add_theme_stylebox_override("panel", style)
		slot.position = Vector2(PAD + i * (SLOT_SIZE + SLOT_GAP), PAD)
		slot.size     = Vector2(SLOT_SIZE, SLOT_SIZE)
		bar.add_child(slot)

		var icon := TextureRect.new()
		icon.expand_mode  = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.anchor_right  = 1.0
		icon.anchor_bottom = 1.0
		icon.offset_left   = 2
		icon.offset_top    = 2
		icon.offset_right  = -2
		icon.offset_bottom = -2
		icon.modulate.a    = 0.0
		slot.add_child(icon)

		var lbl := Label.new()
		lbl.anchor_left   = 0.0
		lbl.anchor_right  = 1.0
		lbl.anchor_top    = 0.5
		lbl.anchor_bottom = 1.0
		lbl.offset_right  = -1
		lbl.offset_bottom = -1
		lbl.add_theme_font_size_override("font_size", 7)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_BOTTOM
		lbl.visible = false
		slot.add_child(lbl)

		var num := Label.new()
		num.text          = str(i + 1)
		num.anchor_left   = 0.0
		num.anchor_right  = 1.0
		num.anchor_top    = 0.0
		num.anchor_bottom = 0.5
		num.offset_left   = 1
		num.offset_top    = 1
		num.add_theme_font_size_override("font_size", 6)
		num.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.7))
		num.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		num.vertical_alignment   = VERTICAL_ALIGNMENT_TOP
		slot.add_child(num)

		_slot_icons.append(icon)
		_slot_labels.append(lbl)
		_slot_styles.append(style)


func _select_slot(idx: int) -> void:
	if idx >= _slot_icons.size():
		return
	_active_slot = idx
	for i in _slot_styles.size():
		var s: StyleBoxFlat = _slot_styles[i]
		if i == idx:
			s.border_color        = Color(0.95, 0.85, 0.25, 1.0)
			s.border_width_left   = 2
			s.border_width_right  = 2
			s.border_width_top    = 2
			s.border_width_bottom = 2
		else:
			s.border_color        = Color(0.45, 0.45, 0.45, 1.0)
			s.border_width_left   = 1
			s.border_width_right  = 1
			s.border_width_top    = 1
			s.border_width_bottom = 1


func get_active_item() -> String:
	if _active_slot >= 0 and _active_slot < _inv_order.size():
		return _inv_order[_active_slot]
	return ""


func add_to_inventory(item_name: String) -> void:
	if _inventory.has(item_name):
		_inventory[item_name] += 1
	else:
		_inventory[item_name] = 1
		_inv_order.append(item_name)
		if _active_slot < 0:
			_select_slot(0)
	_refresh_inv()


func get_inventory_data() -> Dictionary:
	return {
		"inventory": _inventory.duplicate(),
		"order": _inv_order.duplicate(),
		"active": _active_slot
	}


func restore_inventory(data: Dictionary) -> void:
	_inventory = {}
	_inv_order = []
	var saved_inv: Dictionary = data.get("inventory", {})
	var saved_order: Array    = data.get("order", [])
	for item_name in saved_order:
		if saved_inv.has(item_name):
			_inventory[item_name] = saved_inv[item_name]
			_inv_order.append(item_name)
	var active: int = data.get("active", -1)
	if active >= 0 and active < _inv_order.size():
		_select_slot(active)
	elif _inv_order.size() > 0:
		_select_slot(0)
	_refresh_inv()


func _refresh_inv() -> void:
	for i in _slot_icons.size():
		if i < _inv_order.size():
			var iname: String  = _inv_order[i]
			var count: int     = _inventory[iname]
			var tex: Texture2D = ITEM_TEXTURES.get(iname, null) as Texture2D
			_slot_icons[i].texture    = tex
			_slot_icons[i].modulate.a = 1.0
			if count > 1:
				_slot_labels[i].text    = "x%d" % count
				_slot_labels[i].visible = true
			else:
				_slot_labels[i].visible = false
		else:
			_slot_icons[i].modulate.a = 0.0
			_slot_labels[i].visible   = false


func update_progress(v: float) -> void:
	if not prog_bar:
		return
	var tw := create_tween()
	tw.tween_property(prog_bar, "value", v * 100.0, 0.4)


func update_shells(_n: int) -> void:
	pass

func update_item(_name_str: String, _tex: Texture2D = null) -> void:
	pass
