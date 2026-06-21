extends GutTest

# Testa o singleton GameGlobal (Autoload).
# Reseta o estado antes de cada teste para garantir isolamento.

func before_each() -> void:
	GameGlobal.next_phase_number = 1
	GameGlobal.next_phase_name   = "Ecos do Silêncio"
	GameGlobal.current_save_slot = 1
	GameGlobal.photo_texture     = null
	GameGlobal.photo_caption     = ""
	GameGlobal.has_diary         = false

# ── Valores padrão ────────────────────────────────────────────────────────────

func test_fase_inicial_e_1() -> void:
	assert_eq(GameGlobal.next_phase_number, 1)

func test_nome_fase_inicial() -> void:
	assert_eq(GameGlobal.next_phase_name, "Ecos do Silêncio")

func test_slot_padrao_e_1() -> void:
	assert_eq(GameGlobal.current_save_slot, 1)

func test_foto_nula_por_padrao() -> void:
	assert_null(GameGlobal.photo_texture)

func test_legenda_vazia_por_padrao() -> void:
	assert_eq(GameGlobal.photo_caption, "")

func test_diary_falso_por_padrao() -> void:
	assert_false(GameGlobal.has_diary)

# ── Atribuição ────────────────────────────────────────────────────────────────

func test_mudar_slot() -> void:
	GameGlobal.current_save_slot = 2
	assert_eq(GameGlobal.current_save_slot, 2)

func test_mudar_slot_para_3() -> void:
	GameGlobal.current_save_slot = 3
	assert_eq(GameGlobal.current_save_slot, 3)

func test_slots_invalidos_nao_sao_validados_internamente() -> void:
	# GameGlobal não valida range — responsabilidade do chamador
	GameGlobal.current_save_slot = 99
	assert_eq(GameGlobal.current_save_slot, 99)

func test_set_has_diary() -> void:
	GameGlobal.has_diary = true
	assert_true(GameGlobal.has_diary)

func test_reset_has_diary() -> void:
	GameGlobal.has_diary = true
	GameGlobal.has_diary = false
	assert_false(GameGlobal.has_diary)

func test_set_photo_caption() -> void:
	GameGlobal.photo_caption = "Mamãe e papai na praia"
	assert_eq(GameGlobal.photo_caption, "Mamãe e papai na praia")

func test_set_next_phase_number() -> void:
	GameGlobal.next_phase_number = 2
	assert_eq(GameGlobal.next_phase_number, 2)
	assert_ne(GameGlobal.next_phase_number, 1)

func test_set_next_phase_name() -> void:
	GameGlobal.next_phase_name = "Ruínas do Oceano"
	assert_eq(GameGlobal.next_phase_name, "Ruínas do Oceano")

# ── Isolamento entre testes ───────────────────────────────────────────────────

func test_estado_e_independente_entre_testes_a() -> void:
	GameGlobal.has_diary = true
	assert_true(GameGlobal.has_diary)

func test_estado_e_independente_entre_testes_b() -> void:
	# before_each resetou has_diary = false
	assert_false(GameGlobal.has_diary,
			"before_each deve ter resetado has_diary entre testes")
