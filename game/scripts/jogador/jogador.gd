extends CharacterBody2D

@export var tuning: PlayerTuning

@onready var visual: Node2D = $Visual

var direcao_olhar: int = 1

func _physics_process(delta: float) -> void:
	var forca_esquerda := Input.get_action_strength("mover_esquerda")
	var forca_direita := Input.get_action_strength("mover_direita")
	var entrada := EntradaHorizontal.combinar(forca_esquerda, forca_direita, tuning.zona_morta)
	var no_chao := is_on_floor()

	direcao_olhar = DirecaoOlhar.atualizar(direcao_olhar, entrada)
	visual.scale.x = float(direcao_olhar)

	velocity.x = MovimentoHorizontal.atualizar_velocidade(velocity.x, entrada, no_chao, delta, tuning)
	velocity.y = Queda.atualizar_velocidade_vertical(velocity.y, delta, tuning)

	move_and_slide()

## RF-006/RF-008: reposiciona o Zé, zera a velocidade e reseta a direção do
## olhar para a direita. Não acessa nenhum nó da fase — recebe a posição já
## resolvida por parâmetro; quem decide quando chamar isto é fase.gd.
func reaparecer(posicao: Vector2) -> void:
	global_position = posicao
	velocity = Vector2.ZERO
	direcao_olhar = 1
	visual.scale.x = float(direcao_olhar)
