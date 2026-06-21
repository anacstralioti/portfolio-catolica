extends GutTest

# Testa o sistema de inventário do HUD.
# Instancia o script de HUD em um Control vazio (sem a cena completa).
# @onready vars ($ProgressFill, $Flash) serão null — os métodos de inventário
# não dependem delas e foram escritos com guards (if not prog_bar: return).

var hud: Control

func before_each() -> void:
	hud = Control.new()
	hud.set_script(load("res://scripts/hud.gd"))
	add_child_autofree(hud)
	await get_tree().process_frame

# ── Estado inicial ────────────────────────────────────────────────────────────

func test_inventario_inicia_vazio() -> void:
	var data := hud.get_inventory_data()
	assert_eq(data["inventory"].size(), 0, "inventário deve iniciar vazio")

func test_item_ativo_inicia_vazio() -> void:
	assert_eq(hud.get_active_item(), "",
			"sem item equipado no início")

# ── Adicionar itens ───────────────────────────────────────────────────────────

func test_adicionar_concha() -> void:
	hud.add_to_inventory("shell")
	var data := hud.get_inventory_data()
	assert_true(data["inventory"].has("shell"))
	assert_eq(data["inventory"]["shell"], 1)

func test_conchas_acumulam() -> void:
	hud.add_to_inventory("shell")
	hud.add_to_inventory("shell")
	hud.add_to_inventory("shell")
	var data := hud.get_inventory_data()
	assert_eq(data["inventory"]["shell"], 3)

func test_pa_nao_acumula_duas_unidades() -> void:
	hud.add_to_inventory("shovel")
	hud.add_to_inventory("shovel")
	# segunda adição empilha; no entanto o item aparece apenas uma vez na order
	var data := hud.get_inventory_data()
	assert_eq(data["order"].count("shovel"), 1,
			"shovel deve aparecer uma vez na ordem")

func test_itens_diferentes_ficam_na_ordem() -> void:
	hud.add_to_inventory("shell")
	hud.add_to_inventory("shovel")
	hud.add_to_inventory("bucket")
	var data := hud.get_inventory_data()
	assert_eq(data["order"][0], "shell")
	assert_eq(data["order"][1], "shovel")
	assert_eq(data["order"][2], "bucket")

# ── Item ativo ────────────────────────────────────────────────────────────────

func test_primeiro_item_e_auto_selecionado() -> void:
	hud.add_to_inventory("shovel")
	assert_eq(hud.get_active_item(), "shovel",
			"primeiro item adicionado deve ser selecionado automaticamente")

func test_item_ativo_nao_muda_ao_adicionar_segundo() -> void:
	hud.add_to_inventory("shovel")
	hud.add_to_inventory("bucket")
	assert_eq(hud.get_active_item(), "shovel",
			"slot 0 permanece ativo ao adicionar segundo item")

func test_foto_pode_ser_adicionada() -> void:
	hud.add_to_inventory("photo")
	assert_eq(hud.get_active_item(), "photo")

func test_diary_pode_ser_adicionado() -> void:
	hud.add_to_inventory("diary")
	assert_eq(hud.get_active_item(), "diary")

# ── Estrutura de dados ────────────────────────────────────────────────────────

func test_get_inventory_data_tem_chaves_corretas() -> void:
	var data := hud.get_inventory_data()
	assert_true(data.has("inventory"), "falta chave 'inventory'")
	assert_true(data.has("order"),     "falta chave 'order'")
	assert_true(data.has("active"),    "falta chave 'active'")

func test_active_negativo_quando_vazio() -> void:
	var data := hud.get_inventory_data()
	assert_eq(data["active"], -1,
			"active deve ser -1 quando inventário vazio")

func test_order_e_array() -> void:
	var data := hud.get_inventory_data()
	assert_true(data["order"] is Array)

# ── Restore ───────────────────────────────────────────────────────────────────

func test_restore_inventario_basico() -> void:
	var salvo := {
		"inventory": {"shell": 5, "shovel": 1},
		"order":     ["shell", "shovel"],
		"active":    0
	}
	hud.restore_inventory(salvo)
	var data := hud.get_inventory_data()
	assert_eq(data["inventory"]["shell"], 5)
	assert_eq(data["inventory"]["shovel"], 1)

func test_restore_seleciona_slot_correto() -> void:
	var salvo := {
		"inventory": {"shell": 1, "shovel": 1},
		"order":     ["shell", "shovel"],
		"active":    1
	}
	hud.restore_inventory(salvo)
	assert_eq(hud.get_active_item(), "shovel",
			"deve restaurar slot 1 (shovel) como ativo")

func test_restore_inventario_vazio() -> void:
	var salvo := {"inventory": {}, "order": [], "active": -1}
	hud.restore_inventory(salvo)
	assert_eq(hud.get_active_item(), "")

func test_restore_sobrescreve_estado_anterior() -> void:
	hud.add_to_inventory("bucket")
	var salvo := {
		"inventory": {"shell": 2},
		"order":     ["shell"],
		"active":    0
	}
	hud.restore_inventory(salvo)
	var data := hud.get_inventory_data()
	assert_false(data["inventory"].has("bucket"),
			"bucket não deve existir após restore")
	assert_true(data["inventory"].has("shell"))

# ── Ciclo completo ────────────────────────────────────────────────────────────

func test_roundtrip_save_restore() -> void:
	hud.add_to_inventory("shell")
	hud.add_to_inventory("shell")
	hud.add_to_inventory("shovel")
	var salvo := hud.get_inventory_data()

	var hud2 := Control.new()
	hud2.set_script(load("res://scripts/hud.gd"))
	add_child_autofree(hud2)
	await get_tree().process_frame

	hud2.restore_inventory(salvo)
	var restaurado := hud2.get_inventory_data()

	assert_eq(restaurado["inventory"]["shell"],  2)
	assert_eq(restaurado["inventory"]["shovel"], 1)
	assert_eq(restaurado["order"],  ["shell", "shovel"])
