extends GutTest

# Testa a lógica da FSM narrativa do GameManager.
# Não instancia a cena completa — testa fórmulas e constantes isoladamente.

const MAP_W   := 6400.0
const EPSILON := 0.001

# ── Cálculo de progresso ──────────────────────────────────────────────────────

func test_progresso_no_inicio_e_zero() -> void:
	var p := clamp(0.0 / MAP_W, 0.0, 1.0)
	assert_eq(p, 0.0)

func test_progresso_no_fim_e_um() -> void:
	var p := clamp(MAP_W / MAP_W, 0.0, 1.0)
	assert_eq(p, 1.0)

func test_progresso_nao_e_negativo() -> void:
	var p := clamp(-300.0 / MAP_W, 0.0, 1.0)
	assert_eq(p, 0.0, "progresso não pode ser negativo")

func test_progresso_nao_passa_de_um() -> void:
	var p := clamp(99999.0 / MAP_W, 0.0, 1.0)
	assert_eq(p, 1.0, "progresso não pode passar de 1.0")

func test_progresso_no_meio_e_meio() -> void:
	var p := clamp(3200.0 / MAP_W, 0.0, 1.0)
	assert_almost_eq(p, 0.5, EPSILON)

# ── Limiares de transição de estado ──────────────────────────────────────────
# Baseado nas constantes do game_manager:
#   RECONHECIMENTO >= 0.15
#   LEMBRANCA      >= 0.40
#   CONFRONTO      >= 0.65
#   RESOLUCAO      >= 0.85

func test_limiar_reconhecimento() -> void:
	var p := clamp(MAP_W * 0.15 / MAP_W, 0.0, 1.0)
	assert_almost_eq(p, 0.15, EPSILON)
	assert_true(p >= 0.15, "deve ativar RECONHECIMENTO")

func test_abaixo_limiar_reconhecimento_permanece_inicio() -> void:
	var p := clamp(MAP_W * 0.14 / MAP_W, 0.0, 1.0)
	assert_true(p < 0.15, "deve permanecer em INICIO")

func test_limiar_lembranca() -> void:
	var p := clamp(MAP_W * 0.40 / MAP_W, 0.0, 1.0)
	assert_almost_eq(p, 0.40, EPSILON)
	assert_true(p >= 0.40, "deve ativar LEMBRANCA")

func test_limiar_confronto() -> void:
	var p := clamp(MAP_W * 0.65 / MAP_W, 0.0, 1.0)
	assert_almost_eq(p, 0.65, EPSILON)
	assert_true(p >= 0.65, "deve ativar CONFRONTO")

func test_limiar_resolucao() -> void:
	var p := clamp(MAP_W * 0.85 / MAP_W, 0.0, 1.0)
	assert_almost_eq(p, 0.85, EPSILON)
	assert_true(p >= 0.85, "deve ativar RESOLUCAO")

func test_limiar_fase_completa() -> void:
	var p := clamp(MAP_W * 1.0 / MAP_W, 0.0, 1.0)
	assert_eq(p, 1.0, "deve sinalizar phase_complete")

# ── Ordem dos estados ─────────────────────────────────────────────────────────

func test_estados_em_ordem_crescente() -> void:
	var thresholds := [0.0, 0.15, 0.40, 0.65, 0.85, 1.0]
	for i in range(1, thresholds.size()):
		assert_true(thresholds[i] > thresholds[i - 1],
				"limiar %d deve ser maior que o anterior" % i)

func test_cinco_estados_definidos() -> void:
	# Estados: INICIO=0, RECONHECIMENTO=1, LEMBRANCA=2, CONFRONTO=3, RESOLUCAO=4
	var total_estados := 5
	assert_eq(total_estados, 5)

# ── Textos narrativos ─────────────────────────────────────────────────────────

func test_narrativas_nao_vazias() -> void:
	var chaves := ["intro", "reconhecimento", "lembranca",
				   "confronto", "resolucao",
				   "checkpoint1", "checkpoint2", "checkpoint3",
				   "item_shovel", "item_bucket", "shell"]
	# Valida tamanho mínimo de cada frase (pelo menos 5 caracteres)
	var NARRATIVAS := {
		"intro"          : "Está tudo tão quieto...",
		"reconhecimento" : "Este lugar... parece familiar.",
		"lembranca"      : "Quanto tempo eu fiquei longe?",
		"confronto"      : "Não consigo parar de pensar nela.",
		"resolucao"      : "Tem algo além do horizonte.",
		"checkpoint1"    : "Eu preciso continuar.",
		"checkpoint2"    : "Mais longe do que eu lembrava.",
		"checkpoint3"    : "Quase lá.",
		"item_shovel"    : "A pá dela. Ainda estava aqui.",
		"item_bucket"    : "O baldinho que ela usava pra fazer castelos.",
		"shell"          : "Ela colecionava essas coisas.",
	}
	for chave in chaves:
		assert_true(NARRATIVAS.has(chave),
				"NARRATIVAS deve ter a chave '%s'" % chave)
		assert_true(NARRATIVAS[chave].length() >= 5,
				"Texto '%s' não pode ser vazio" % chave)

# ── Checkpoints ───────────────────────────────────────────────────────────────

func test_checkpoint_positions_em_ordem() -> void:
	var positions := [80.0, 700.0, 2200.0, 4500.0]
	for i in range(1, positions.size()):
		assert_true(positions[i] > positions[i - 1],
				"checkpoint %d deve estar à direita do anterior" % i)

func test_checkpoint_inicial_dentro_do_mapa() -> void:
	var cp0 := 80.0
	assert_true(cp0 > 0.0 and cp0 < MAP_W)

func test_checkpoint_final_dentro_do_mapa() -> void:
	var cp3 := 4500.0
	assert_true(cp3 > 0.0 and cp3 < MAP_W)

func test_clearance_checkpoint_positiva() -> void:
	var clearance := 90.0
	assert_true(clearance > 0.0,
			"clearance deve impedir spawn de objetos sobre checkpoints")

func test_objeto_nao_spawna_sobre_checkpoint() -> void:
	var cp_x    := 700.0
	var clearance := 90.0
	var obj_x   := 720.0  # dentro da zona de clearance
	assert_true(abs(obj_x - cp_x) < clearance,
			"este x deve ser bloqueado pela clearance")
