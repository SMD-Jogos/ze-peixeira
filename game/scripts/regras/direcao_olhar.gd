class_name DirecaoOlhar
extends RefCounted

## RF-005: a direção do olhar é o sinal da última entrada horizontal
## diferente de zero — muda só quando entrada != 0; com entrada 0, mantém
## a direção atual. entrada já vem discretizada por EntradaHorizontal.
static func atualizar(direcao_atual: int, entrada: int) -> int:
	if entrada == 0:
		return direcao_atual
	return entrada
