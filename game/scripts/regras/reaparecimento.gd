class_name RegraReaparecimento
extends RefCounted

## RF-006: decide se o Zé deve reaparecer, comparando sua posição vertical
## com o limite inferior da fase. y maior = mais abaixo na tela (eixo Y do
## Godot 2D cresce para baixo).
static func deve_reaparecer(y: float, limite: float) -> bool:
	return y > limite
