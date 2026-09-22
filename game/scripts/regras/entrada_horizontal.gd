class_name EntradaHorizontal
extends RefCounted

## RF-001: arredonda a entrada horizontal bruta (analógica ou digital) para
## -1, 0 ou 1, aplicando a zona morta de PlayerTuning.zona_morta.
static func arredondar(bruto: float, zona_morta: float) -> int:
	if abs(bruto) < zona_morta:
		return 0
	return 1 if bruto > 0.0 else -1

## Combina a força das duas ações (mover_esquerda, mover_direita) — direita
## menos esquerda — e já arredonda o resultado. mover_esquerda e
## mover_direita pressionadas juntas resultam nas duas forças iguais, cuja
## subtração é 0, arredondada para 0 pela zona morta (Casos-limite da spec).
static func combinar(forca_esquerda: float, forca_direita: float, zona_morta: float) -> int:
	return arredondar(forca_direita - forca_esquerda, zona_morta)
