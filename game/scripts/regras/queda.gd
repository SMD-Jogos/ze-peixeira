class_name Queda
extends RefCounted

## RF-004: soma gravidade * delta à velocidade vertical a cada tick,
## até o limite queda_max.
static func atualizar_velocidade_vertical(velocidade_vertical_atual: float, delta: float, tuning: PlayerTuning) -> float:
	return minf(velocidade_vertical_atual + tuning.gravidade * delta, tuning.queda_max)
