# Fatia 003 — Máquina de estados do jogador

**Status:** especificação escrita pelo humano · **Depende de:** 001-movimento, 002-pulo

## Objetivo

Refatorar o controlador para estados explícitos (padrão **State**, capítulo "State" de *Game Programming Patterns*), **sem mudar nenhum comportamento**. É uma fatia de engenharia, não de jogo: o jogador não deve perceber diferença.

## Por que agora

Depois das fatias 001 e 002, o controlador decide o que fazer combinando indicadores (está no chão? pulou? ainda no tempo de altura variável?). As fatias 004 a 006 acrescentam dash, morte e reaparecimento, e cada uma multiplicaria essas combinações. Com estados explícitos, cada comportamento fica num lugar só, e acrescentar um estado não exige mexer nos outros.

## Cenários de aceitação

1. **Dado** o jogo depois da refatoração, **quando** o jogador executa qualquer sequência de corrida e pulo, **então** o comportamento é idêntico ao anterior.
2. **Dado** o modo de depuração ligado, **então** o nome do estado atual aparece acima do Zé.

## Requisitos funcionais

- **RF-001** Estados iniciais: `NoChao` e `NoAr`. Nenhum outro estado é criado nesta fatia.
- **RF-002** Cada estado é um objeto próprio com, no mínimo, `entrar()`, `sair()` e `processar_fisica(delta)`.
- **RF-003** Há um único estado ativo por vez. A troca de estado passa sempre pela máquina, que chama `sair()` do estado atual e `entrar()` do novo.
- **RF-004** O plano traz uma **tabela de transições** (estado de origem, condição, estado de destino), e o código corresponde a ela.
- **RF-005** As classes puras de regras das fatias 001 e 002 continuam sendo usadas pelos estados. A lógica não é duplicada dentro deles.
- **RF-006** Com `depuracao_estados` ligado no `PlayerTuning`, um `Label` acima do Zé mostra o nome do estado ativo.
- **RF-007** Os arquivos de teste das fatias 001 e 002 não são alterados e continuam passando.

## Fora do escopo

Qualquer comportamento novo; máquina de estados hierárquica ou com pilha (*pushdown automata*); estados só visuais (como separar `Parado` de `Correndo`), que não mudam regras.

## Critérios de sucesso

- **CS-001** `git diff` sobre `game/tests/test_001_*.gd` e `game/tests/test_002_*.gd` vazio, e todos passando.
- **CS-002** A tabela de transições do plano e o código conferem, item a item, na revisão.
- **CS-003** O script do nó do jogador não contém mais decisões de movimento: só lê entrada, delega ao estado ativo e chama `move_and_slide()`.
- **CS-004** Existe teste GUT para cada transição da tabela.
