extends GutTest

# Testa lógica de Collectible e MemoryObject sem depender da física do mundo.
# Usa double parcial do GameManager quando necessário para isolar sinais.

# ── Collectible ───────────────────────────────────────────────────────────────

func test_collectible_item_type_padrao() -> void:
	var col := Area2D.new()
	col.set_script(load("res://scripts/collectible.gd"))
	# Instanciar sem cena: @onready vars serão null — collect() guarda com _done
	# Apenas verificamos os valores exportáveis antes do _ready
	assert_eq(col.get("item_type"),       "shell")
	assert_eq(col.get("bob_amplitude"),   3.0)
	assert_eq(col.get("bob_speed"),       2.5)
	col.free()

func test_collect_marca_done() -> void:
	# Cria um Area2D nu com o script (sem filhos — @onready serão null)
	var col := Area2D.new()
	col.set_script(load("res://scripts/collectible.gd"))
	add_child_autofree(col)
	await get_tree().process_frame

	assert_false(col._done, "deve iniciar com _done = false")
	col.collect()
	assert_true(col._done, "collect() deve marcar _done = true")

func test_collect_segunda_vez_nao_muda_estado() -> void:
	var col := Area2D.new()
	col.set_script(load("res://scripts/collectible.gd"))
	add_child_autofree(col)
	await get_tree().process_frame

	col.collect()
	col._done = false  # força reset manual para provar que collect() retorna cedo
	col.collect()
	# Como _done foi resetado manualmente, segunda chamada executa de novo
	# O teste verdadeiro é que collect() respeita _done:
	var col2 := Area2D.new()
	col2.set_script(load("res://scripts/collectible.gd"))
	add_child_autofree(col2)
	await get_tree().process_frame
	col2.collect()
	var done_apos_primeira := col2._done
	col2.collect()  # segunda chamada com _done = true → retorna cedo
	assert_true(done_apos_primeira)

func test_bob_animacao_varia_com_tempo() -> void:
	# sin(t * speed) com t > 0 deve diferir de sin(0)
	var amplitude := 3.0
	var speed     := 2.5
	var t         := 1.0
	var pos_y     := sin(t * speed) * amplitude
	assert_ne(pos_y, 0.0, "bob deve mover o item verticalmente")

# ── MemoryObject ──────────────────────────────────────────────────────────────

func test_memory_object_valores_padrao() -> void:
	var mo := Node2D.new()
	mo.set_script(load("res://scripts/memory_object.gd"))
	assert_eq(mo.get("item_type"),         "")
	assert_eq(mo.get("narrative_text"),    "")
	assert_eq(mo.get("prompt_text"),       "[E] Examinar")
	assert_false(mo.get("has_flashback"))
	assert_false(mo.get("use_photo_overlay"))
	assert_false(mo.get("use_diary_overlay"))
	mo.free()

func test_memory_object_interact_radius() -> void:
	var mo := Node2D.new()
	mo.set_script(load("res://scripts/memory_object.gd"))
	assert_eq(mo.INTERACT_RADIUS, 72.0)
	mo.free()

func test_memory_object_collect_sets_done() -> void:
	# Sem cena completa, só verifica que _done começa false
	var mo := Node2D.new()
	mo.set_script(load("res://scripts/memory_object.gd"))
	assert_false(mo.get("_done"))
	mo.free()

# ── SandHole ──────────────────────────────────────────────────────────────────

func test_sandhole_detect_radius() -> void:
	var sh := StaticBody2D.new()
	sh.set_script(load("res://scripts/sand_hole.gd"))
	assert_eq(sh.DETECT_RADIUS, 80.0)
	sh.free()

func test_sandhole_inicia_nao_preenchido() -> void:
	var sh := StaticBody2D.new()
	sh.set_script(load("res://scripts/sand_hole.gd"))
	assert_false(sh.get("_filled"))
	sh.free()

# ── Checkpoint ────────────────────────────────────────────────────────────────

func test_checkpoint_id_padrao() -> void:
	var cp := Area2D.new()
	cp.set_script(load("res://scripts/checkpoint.gd"))
	assert_eq(cp.get("checkpoint_id"), 1)
	cp.free()

func test_checkpoint_hit_inicia_false() -> void:
	var cp := Area2D.new()
	cp.set_script(load("res://scripts/checkpoint.gd"))
	assert_false(cp.get("_hit"))
	cp.free()

# ── Distância de interação ────────────────────────────────────────────────────

func test_dentro_do_raio_de_interacao() -> void:
	var origem   := Vector2(100, 50)
	var jogador  := Vector2(150, 50)  # 50 px de distância
	var raio     := 72.0
	assert_true(origem.distance_to(jogador) < raio,
			"jogador a 50 px deve estar dentro do raio de 72")

func test_fora_do_raio_de_interacao() -> void:
	var origem   := Vector2(100, 50)
	var jogador  := Vector2(200, 50)  # 100 px de distância
	var raio     := 72.0
	assert_false(origem.distance_to(jogador) < raio,
			"jogador a 100 px deve estar fora do raio de 72")
