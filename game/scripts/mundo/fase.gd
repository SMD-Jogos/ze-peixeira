extends Node2D

@export var limite_inferior_fase: float = 0.0

@onready var jogador: CharacterBody2D = $Jogador
@onready var ponto_inicial: Marker2D = $PontoInicial

# A árvore de cena chama _ready() dos filhos antes do pai (Godot entra na
# árvore de baixo para cima na primeira vez). Por isso, quando este
# _ready() roda, o Jogador já terminou o seu próprio _ready() — @onready
# var jogador acima já está resolvido, e é seguro chamar reaparecer() aqui
# para cobrir o RF-008 no início da fase.
func _ready() -> void:
	jogador.reaparecer(ponto_inicial.global_position)

# Ao contrário do _ready(), _physics_process roda do pai para os filhos a
# cada tick (o pai primeiro). Isso significa que, aqui, jogador.global_position
# ainda reflete o fim do tick ANTERIOR — o Zé só se move depois, no seu
# próprio _physics_process, que roda em seguida neste mesmo tick. Ou seja,
# a checagem de RF-006 tem 1 tick de atraso em relação ao movimento que a
# causou. Aceitável: a spec não exige detectar isso no mesmo tick da queda.
func _physics_process(_delta: float) -> void:
	if RegraReaparecimento.deve_reaparecer(jogador.global_position.y, limite_inferior_fase):
		jogador.reaparecer(ponto_inicial.global_position)
