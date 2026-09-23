extends GutTest

const TICK := 1.0 / 60.0

var tuning: PlayerTuning

func before_each():
	tuning = PlayerTuning.new()
	tuning.corrida_max = 90.0
	tuning.corrida_aceleracao = 1000.0
	tuning.corrida_reducao = 400.0
	tuning.multiplicador_ar = 0.65
	tuning.gravidade = 900.0
	tuning.queda_max = 160.0
	tuning.zona_morta = 0.2

# RF-001

func test_rf001_abaixo_da_zona_morta_vira_zero():
	assert_eq(EntradaHorizontal.arredondar(0.1, tuning.zona_morta), 0)
	assert_eq(EntradaHorizontal.arredondar(-0.1, tuning.zona_morta), 0)

func test_rf001_acima_da_zona_morta_arredonda_para_sinal():
	assert_eq(EntradaHorizontal.arredondar(0.3, tuning.zona_morta), 1)
	assert_eq(EntradaHorizontal.arredondar(-0.3, tuning.zona_morta), -1)

func test_rf001_combinar_esquerda_e_direita():
	assert_eq(EntradaHorizontal.combinar(1.0, 1.0, tuning.zona_morta), 0, "ambas pressionadas com a mesma força se cancelam")
	assert_eq(EntradaHorizontal.combinar(0.0, 1.0, tuning.zona_morta), 1, "só direita")
	assert_eq(EntradaHorizontal.combinar(1.0, 0.0, tuning.zona_morta), -1, "só esquerda")

func test_rf001_limiar_exato_da_zona_morta_conta():
	assert_eq(EntradaHorizontal.arredondar(0.2, tuning.zona_morta), 1)
	assert_eq(EntradaHorizontal.arredondar(-0.2, tuning.zona_morta), -1)

# RF-002, CS-001, CS-002

func test_rf002_acelera_ate_corrida_max():
	var v := 0.0
	for i in range(10):
		v = MovimentoHorizontal.atualizar_velocidade(v, 1, true, TICK, tuning)
	assert_almost_eq(v, tuning.corrida_max, 0.001)

func test_rf002_reduz_com_corrida_reducao_acima_do_maximo():
	var v := 120.0
	var nova := MovimentoHorizontal.atualizar_velocidade(v, 1, true, TICK, tuning)
	var esperado := v - tuning.corrida_reducao * TICK
	assert_almost_eq(nova, esperado, 0.001)
	assert_true(nova > tuning.corrida_max, "reducao é gradual, não corta de uma vez")

func test_cs001_atinge_corrida_max_no_tick_6():
	var v := 0.0
	for i in range(5):
		v = MovimentoHorizontal.atualizar_velocidade(v, 1, true, TICK, tuning)
	assert_true(v < tuning.corrida_max, "tick 5 deve ficar abaixo de corrida_max")
	assert_almost_eq(v, 83.333, 0.01, "tick 5 deve ser 83,333 px/s, como a spec descreve")
	v = MovimentoHorizontal.atualizar_velocidade(v, 1, true, TICK, tuning)
	assert_almost_eq(v, tuning.corrida_max, 0.001, "tick 6 deve atingir corrida_max exatamente")

func test_cs002_para_no_tick_6_sem_trocar_sinal():
	var v := tuning.corrida_max
	for i in range(5):
		v = MovimentoHorizontal.atualizar_velocidade(v, 0, true, TICK, tuning)
	assert_true(v > 0.0, "tick 5 deve continuar positivo")
	assert_almost_eq(v, 6.667, 0.01, "tick 5 deve ser 6,667 px/s")
	v = MovimentoHorizontal.atualizar_velocidade(v, 0, true, TICK, tuning)
	assert_almost_eq(v, 0.0, 0.001, "tick 6 deve parar exatamente, sem trocar de sinal")

func test_rf003_multiplicador_ar_reduz_taxa():
	# Ramo de aceleração (corrida_aceleracao): incremento no ar deve ser
	# exatamente multiplicador_ar vezes o incremento no chão, no mesmo tick.
	var chao_aceleracao := MovimentoHorizontal.atualizar_velocidade(0.0, 1, true, TICK, tuning)
	var ar_aceleracao := MovimentoHorizontal.atualizar_velocidade(0.0, 1, false, TICK, tuning)
	assert_almost_eq(ar_aceleracao, chao_aceleracao * tuning.multiplicador_ar, 0.001, "incremento no ar = multiplicador_ar * incremento no chão (aceleração)")

	# Ramo de redução (corrida_reducao): mesma proporção, com |v| > corrida_max
	# no mesmo sentido da entrada (estado contrivado, possível com dash em fatia futura).
	var v_inicial := 120.0
	var chao_reducao := MovimentoHorizontal.atualizar_velocidade(v_inicial, 1, true, TICK, tuning) - v_inicial
	var ar_reducao := MovimentoHorizontal.atualizar_velocidade(v_inicial, 1, false, TICK, tuning) - v_inicial
	assert_almost_eq(ar_reducao, chao_reducao * tuning.multiplicador_ar, 0.001, "incremento no ar = multiplicador_ar * incremento no chão (redução)")

# RF-005 (Cenário 3)

func test_rf005_muda_no_tick_em_que_a_entrada_muda_de_sinal():
	assert_eq(DirecaoOlhar.atualizar(1, -1), -1, "muda para esquerda assim que a entrada é -1")
	assert_eq(DirecaoOlhar.atualizar(-1, 1), 1, "muda para direita assim que a entrada é 1")

func test_rf005_mantem_direcao_com_entrada_zero():
	assert_eq(DirecaoOlhar.atualizar(1, 0), 1, "mantém direita com entrada 0")
	assert_eq(DirecaoOlhar.atualizar(-1, 0), -1, "mantém esquerda com entrada 0")

# RF-004, CS-003

func test_rf004_gravidade_acumula_por_tick():
	var v := 0.0
	v = Queda.atualizar_velocidade_vertical(v, TICK, tuning)
	assert_almost_eq(v, 15.0, 0.001, "gravidade * delta no primeiro tick")
	v = Queda.atualizar_velocidade_vertical(v, TICK, tuning)
	assert_almost_eq(v, 30.0, 0.001, "acumula no segundo tick")

func test_cs003_nunca_ultrapassa_queda_max():
	var v := tuning.queda_max - 5.0
	v = Queda.atualizar_velocidade_vertical(v, TICK, tuning)
	assert_eq(v, tuning.queda_max, "clampeia no limite quando o incremento ultrapassaria")
	v = Queda.atualizar_velocidade_vertical(v, TICK, tuning)
	assert_eq(v, tuning.queda_max, "permanece no limite em queda livre prolongada")

# RF-006, RF-008

func test_rf006_reaparece_abaixo_do_limite():
	assert_true(RegraReaparecimento.deve_reaparecer(201.0, 200.0), "acima do limite (y maior) deve reaparecer")
	assert_false(RegraReaparecimento.deve_reaparecer(200.0, 200.0), "exatamente no limite ainda não é 'abaixo'")
	assert_false(RegraReaparecimento.deve_reaparecer(199.0, 200.0), "antes do limite não reaparece")

func test_rf008_estado_apos_reaparecer_e_no_inicio():
	var jogador_cena: PackedScene = load("res://scenes/jogador.tscn")
	var jogador: CharacterBody2D = add_child_autofree(jogador_cena.instantiate())
	jogador.tuning = tuning

	jogador.velocity = Vector2(42.0, -13.0)
	jogador.direcao_olhar = -1

	var posicao_alvo := Vector2(60.0, 114.5)
	jogador.reaparecer(posicao_alvo)

	assert_eq(jogador.velocity, Vector2.ZERO, "reaparecer zera a velocidade")
	assert_eq(jogador.direcao_olhar, 1, "reaparecer reseta a direção para a direita")
	assert_eq(jogador.global_position, posicao_alvo, "reaparecer aplica a posição recebida")

# T011 (convergência, achado F1): integração real de fase.gd — não só a
# regra pura nem reaparecer() isolado, mas a orquestração de fase_teste.tscn.

func test_fase_posiciona_jogador_no_ready():
	var fase_cena: PackedScene = load("res://scenes/fase_teste.tscn")
	var fase: Node2D = fase_cena.instantiate()
	var jogador: CharacterBody2D = fase.get_node("Jogador")
	var ponto_inicial: Marker2D = fase.get_node("PontoInicial")

	# Estado deliberadamente diferente do que a cena já traz por padrão —
	# senão o teste passaria mesmo que _ready() nunca chamasse reaparecer(),
	# só porque jogador.tscn já nasce posicionado sobre o PontoInicial.
	jogador.global_position = Vector2.ZERO
	jogador.velocity = Vector2(50.0, 50.0)
	jogador.direcao_olhar = -1

	add_child_autofree(fase)

	assert_eq(jogador.global_position, ponto_inicial.global_position, "_ready() da fase posiciona o Zé no PontoInicial (RF-008)")
	assert_eq(jogador.velocity, Vector2.ZERO, "_ready() da fase zera a velocidade")
	assert_eq(jogador.direcao_olhar, 1, "_ready() da fase olha para a direita")

func test_fase_reaparece_apos_tick_de_fisica_abaixo_do_limite():
	var fase_cena: PackedScene = load("res://scenes/fase_teste.tscn")
	var fase: Node2D = add_child_autofree(fase_cena.instantiate())
	var jogador: CharacterBody2D = fase.get_node("Jogador")
	var ponto_inicial: Marker2D = fase.get_node("PontoInicial")

	jogador.global_position = Vector2(60.0, fase.limite_inferior_fase + 1.0)
	jogador.velocity = Vector2(30.0, 160.0)
	jogador.direcao_olhar = -1

	fase._physics_process(TICK)

	assert_eq(jogador.global_position, ponto_inicial.global_position, "abaixo do limite, reaparece após o tick de física da fase")
	assert_eq(jogador.velocity, Vector2.ZERO, "reaparecer zera a velocidade")
	assert_eq(jogador.direcao_olhar, 1, "reaparecer reseta a direção para a direita")
