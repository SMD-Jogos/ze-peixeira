extends CharacterBody2D

@export var tuning: PlayerTuning

func _physics_process(delta: float) -> void:
	var forca_esquerda := Input.get_action_strength("mover_esquerda")
	var forca_direita := Input.get_action_strength("mover_direita")
	var entrada := EntradaHorizontal.combinar(forca_esquerda, forca_direita, tuning.zona_morta)
	var no_chao := is_on_floor()

	velocity.x = MovimentoHorizontal.atualizar_velocidade(velocity.x, entrada, no_chao, delta, tuning)
	velocity.y = Queda.atualizar_velocidade_vertical(velocity.y, delta, tuning)

	move_and_slide()
