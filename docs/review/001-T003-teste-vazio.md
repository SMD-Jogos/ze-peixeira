# Revisão 001-T003 — teste vazio para o caso-limite "ambas as direções"

**Fatia:** 001-movimento · **Tarefa:** T003 · **Agente e modelo:** Claude Code, Sonnet 5 · **Data:** 2026-09-22

## O que foi pedido

Trecho de `tasks.md` (T003): testes, entre outros, `test_rf001_ambas_direcoes_resultam_zero` (achado E2 do `/speckit.analyze`: `mover_esquerda` e `mover_direita` juntas → entrada 0).

## O que veio

O agente escreveu, em `game/tests/test_001_movimento.gd`:

```gdscript
func test_rf001_ambas_direcoes_resultam_zero():
	# mover_esquerda e mover_direita juntas: Input.get_axis já devolve 0.0.
	assert_eq(EntradaHorizontal.arredondar(0.0, tuning.zona_morta), 0)
```

## Problema

Tipo:

- [ ] API inexistente ou do Godot 3
- [ ] Violação da constituição (qual item: ___)
- [ ] Critério de aceitação não atendido (qual: ___)
- [ ] Escopo além da tarefa ou da spec
- [x] Teste que não testa o critério
- [ ] Ambiguidade da spec (o agente não errou; a spec permitia essa leitura)

Descrição: o teste chama `EntradaHorizontal.arredondar(0.0, ...)` — mas `0.0` já é o valor de entrada, não o resultado de combinar duas direções pressionadas. Quem de fato calculava "direita menos esquerda" era `Input.get_axis()`, dentro de `jogador.gd`, **fora** do que o teste exercita. O teste só provava que `arredondar(0.0, ...) == 0`, um caso já coberto por `test_rf001_abaixo_da_zona_morta_vira_zero` — não provava nada sobre o comportamento de "as duas direções pressionadas juntas", que é o que o achado E2 pedia para cobrir. Era, na prática, um teste vazio disfarçado de teste do caso-limite.

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

> `test_rf001_ambas_direcoes_resultam_zero` é um teste vazio: testa `arredondar(0.0)`, e quem combina as direções é `Input.get_axis`, fora do teste. Mova a combinação para a regra pura: `EntradaHorizontal.combinar(forca_esquerda: float, forca_direita: float, zona_morta: float) -> int`, que faz direita − esquerda e arredonda. `jogador.gd` passa `Input.get_action_strength` das duas ações. Teste: `combinar(1.0, 1.0) == 0`, `combinar(0.0, 1.0) == 1`, `combinar(1.0, 0.0) == -1`.

Resultado: `EntradaHorizontal.combinar()` criado em `game/scripts/regras/entrada_horizontal.gd`, movendo a subtração "direita menos esquerda" para dentro da classe pura. `jogador.gd` passa a ler `Input.get_action_strength("mover_esquerda")` e `Input.get_action_strength("mover_direita")` e chamar `combinar()`, em vez de `Input.get_axis()` + `arredondar()`. O teste vazio foi substituído por `test_rf001_combinar_esquerda_e_direita`, que agora exercita a combinação de verdade dentro da regra pura.

## Lição

Um teste que chama a regra pura com um valor já pré-calculado por código fora do teste (ou fora da regra) não testa o comportamento que deveria cobrir — só testa um caso que provavelmente já está coberto por outro teste. Se o caso-limite envolve combinar duas entradas, a combinação precisa acontecer dentro da própria regra pura testada, não ser simulada manualmente no teste.
