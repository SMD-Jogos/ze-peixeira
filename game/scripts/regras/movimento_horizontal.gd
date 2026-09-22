class_name MovimentoHorizontal
extends RefCounted

## RF-002/RF-003: aproxima a velocidade horizontal do alvo (entrada * corrida_max),
## sem nunca ultrapassá-lo. no_chao ainda não é usado nesta tarefa (RF-003, T006).
static func atualizar_velocidade(velocidade_atual: float, entrada: int, no_chao: bool, delta: float, tuning: PlayerTuning) -> float:
	var alvo := float(entrada) * tuning.corrida_max

	var sinal_v := 0
	if velocidade_atual > 0.0:
		sinal_v = 1
	elif velocidade_atual < 0.0:
		sinal_v = -1

	var usa_reducao: bool = abs(velocidade_atual) > tuning.corrida_max and entrada != 0 and sinal_v == entrada
	var taxa := tuning.corrida_reducao if usa_reducao else tuning.corrida_aceleracao

	return move_toward(velocidade_atual, alvo, taxa * delta)
