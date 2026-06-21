extends Node

# Inventário linear, versão simplificada usada internamente (sem UI própria).

signal inventory_changed
signal active_item_changed

var items: Array[String] = []
var active_item_index: int = 0


func add_item(item_name: String) -> void:
	items.append(item_name)
	inventory_changed.emit()
	if items.size() == 1:
		active_item_changed.emit()  # primeiro item automaticamente ativo


func remove_item(item_name: String) -> void:
	if items.has(item_name):
		items.erase(item_name)
		# Corrige o índice se o item removido estava após o slot ativo
		if active_item_index >= items.size():
			active_item_index = max(0, items.size() - 1)
		inventory_changed.emit()
		active_item_changed.emit()


func next_item() -> void:
	if items.size() > 0:
		active_item_index = (active_item_index + 1) % items.size()
		active_item_changed.emit()


func prev_item() -> void:
	if items.size() > 0:
		active_item_index = (active_item_index - 1 + items.size()) % items.size()
		active_item_changed.emit()


func get_active_item() -> String:
	if items.size() > 0 and active_item_index < items.size():
		return items[active_item_index]
	return ""
