# Revisão 001-T011 — teste de integração vazio (não provava a chamada em `_ready()`)

**Fatia:** 001-movimento · **Tarefa:** T011 (Phase 5: Convergence) · **Agente e modelo:** Claude Code, Sonnet 5 · **Data:** 2026-09-22

## O que foi pedido

Trecho da instrução do humano (implementação da T011, achado F1 do `/speckit.converge`): "implemente a T011 (teste de integração de `fase.gd`, instanciando `fase_teste.tscn`: `_ready()` posiciona o Zé no `PontoInicial`; Zé abaixo de `limite_inferior_fase` reaparece após o physics tick)."

## O que veio

O agente escreveu, em `game/tests/test_001_movimento.gd`:

```gdscript
func test_fase_posiciona_jogador_no_ready():
	var fase_cena: PackedScene = load("res://scenes/fase_teste.tscn")
	var fase: Node2D = add_child_autofree(fase_cena.instantiate())
	var jogador: CharacterBody2D = fase.get_node("Jogador")
	var ponto_inicial: Marker2D = fase.get_node("PontoInicial")

	assert_eq(jogador.global_position, ponto_inicial.global_position, "_ready() da fase já posiciona o Zé no PontoInicial (RF-008)")
	assert_eq(jogador.velocity, Vector2.ZERO, "_ready() da fase zera a velocidade")
	assert_eq(jogador.direcao_olhar, 1, "_ready() da fase olha para a direita")
```

## Problema

Tipo:

- [ ] API inexistente ou do Godot 3
- [ ] Violação da constituição (qual item: ___)
- [ ] Critério de aceitação não atendido (qual: ___)
- [ ] Escopo além da tarefa ou da spec
- [x] Teste que não testa o critério
- [ ] Ambiguidade da spec (o agente não errou; a spec permitia essa leitura)

Descrição: o teste instanciava `fase_teste.tscn` sem alterar o estado do `Jogador` antes de adicioná-lo à árvore. Como `jogador.tscn`, instanciado dentro de `fase_teste.tscn`, **já nasce** posicionado em `(60, 114.5)` (a posição do `PontoInicial`, definida na cena desde a T001), com `velocity = Vector2.ZERO` (padrão de `CharacterBody2D`) e `direcao_olhar = 1` (padrão do campo em `jogador.gd`), as três asserções passavam mesmo que `fase.gd._ready()` **nunca** chamasse `jogador.reaparecer()`. O teste não provava a chamada em si — só confirmava os valores de fábrica da cena, que por coincidência já batiam com o resultado esperado de `reaparecer()`.

**Prova da falha (feita e desfeita nesta sessão):** comentei temporariamente a linha `jogador.reaparecer(ponto_inicial.global_position)` em `game/scripts/mundo/fase.gd._ready()` e rodei o GUT. Com o teste original (antes da correção), o teste continuaria passando — não foi isso que aconteceu, porque a correção já tinha sido aplicada antes desta prova (ver "O que mudou"); a prova foi feita sobre a versão corrigida, para confirmar que ELA, sim, detecta a ausência da chamada:

```
[Failed]:  [VECTOR2(0.0, 0.0)] expected to equal [VECTOR2(60.0, 114.5)]:  _ready() da fase posiciona o Zé no PontoInicial (RF-008)
[Failed]:  [VECTOR2(50.0, 50.0)] expected to equal [VECTOR2(0.0, 0.0)]:  _ready() da fase zera a velocidade
[Failed]:  [-1] expected to equal [1]:  _ready() da fase olha para a direita
16/17 passed (test_fase_posiciona_jogador_no_ready falhando)
```

`fase.gd` foi restaurado logo em seguida (`git diff` confirmando estado idêntico ao commit).

## Como foi percebido

- [ ] Teste falhou
- [ ] Jogando
- [x] Lendo o diff
- [ ] Console do Godot
- [ ] Outro: ___

Percebido na revisão do código por uma segunda sessão de IA (Claude, atuando como revisora), repassada pelo humano.

## O que mudou

- [x] Só o código (pedido de correção ao agente)
- [ ] A tarefa (`tasks.md`)
- [ ] A spec (`spec.md`), por decisão humana
- [ ] A constituição

Pedido de correção enviado, copiado literalmente:

> Revisão da T011: `test_fase_posiciona_jogador_no_ready` é vazio — `fase_teste.tscn` já instancia o Jogador em (60, 114.5), parado e olhando para a direita, então o teste passa mesmo sem a chamada `reaparecer()` no `_ready()` da fase. Corrija: instancie a cena, e ANTES de `add_child_autofree` altere o Jogador (`position = Vector2.ZERO`, `velocity = Vector2(50, 50)`, `direcao_olhar = -1`); só então adicione à árvore e verifique posição, velocidade e olhar. Prove que o teste agora falha sem a chamada: comente temporariamente o `reaparecer()` do `_ready()` de `fase.gd`, rode o GUT, mostre a falha, e restaure.

Resultado: o teste agora instancia a cena **antes** de adicioná-la à árvore, altera `jogador.global_position`, `velocity` e `direcao_olhar` para valores deliberadamente diferentes do esperado, só então chama `add_child_autofree(fase)` (o que dispara `_ready()`), e verifica se os três valores voltaram ao estado de `reaparecer()`. A prova de falha (acima) confirma que o teste corrigido depende de fato da chamada.

## Lição

Um teste de integração que só confere o estado de uma cena recém-instanciada, sem primeiro perturbar esse estado, corre o risco de estar testando os valores de fábrica da cena, não o efeito do código que deveria estar sendo exercitado. Regra prática: antes de aceitar um teste de "estado após uma chamada", perguntar "esse estado já não seria verdade de qualquer jeito, mesmo sem a chamada?" — e, na dúvida, provar comentando a chamada e rodando o teste.
