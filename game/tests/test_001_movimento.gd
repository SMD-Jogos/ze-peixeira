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
