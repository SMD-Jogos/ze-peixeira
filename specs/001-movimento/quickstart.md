# Quickstart: validar a fatia 001-movimento

## Pré-requisitos

- Godot 4.7.2 no PATH (`godot --version`).
- GUT instalado e plugin ativado (Passo 0/1) — `game/addons/gut`.
- `game/scenes/fase_teste.tscn` e `game/scripts/` implementados (tarefas do `/speckit.tasks`).

## Validação automatizada (GUT)

```bash
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

Esperado: todos os testes de `game/tests/test_001_movimento.gd` passando — ver a tabela RF/CS → teste em `plan.md`, seção "Estratégia de testes". Nenhum teste de fatia anterior existe ainda para regredir (constituição 4.4 passa a valer a partir da fatia 002).

## Validação manual (playtest, com teclado e com controle)

Abrir `game/scenes/fase_teste.tscn` no editor e rodar (F6). Testar, um de cada vez:

1. Segurar `mover_direita` parado no chão → acelera até `corrida_max` e mantém (Cenário 1).
2. Soltar a direção enquanto corre → desacelera até parar, sem inverter (Cenário 2).
3. Correndo para a direita, segurar `mover_esquerda` → desacelera, inverte, acelera para a esquerda; o Zé já olha para a esquerda no instante em que a entrada muda, antes de a velocidade terminar de inverter (Cenário 3).
4. Sair andando de uma plataforma e segurar uma direção no ar → acelera mais devagar que no chão (Cenário 4).
5. Andar para fora de uma plataforma, sem chão embaixo → cai com aceleração constante até `queda_max` (Cenário 5).
6. Correr contra a parede da fase → para na horizontal, não atravessa (Cenário 6).
7. Cair no vão da fase, abaixo de `limite_inferior_fase` → volta ao `PontoInicial`, parado, olhando para a direita (Cenário 7, RF-006, RF-008).
8. Checar visualmente que a fase inteira (chão, 2 plataformas, parede, vão) cabe na tela 320×180 sem a câmera se mover (RF-007).
9. Se um controle com analógico estiver disponível: mover o analógico levemente (dentro da zona morta de 0,2) não deve mover o Zé; passar de 0,2 deve mover (RF-001) — depende da Decisão 1 de `research.md` (baixar o `deadzone` do `InputMap`) já ter sido aplicada numa tarefa.

## Resultado esperado

Todos os 7 cenários de aceitação e os 4 critérios de sucesso (CS-001 a CS-004) da spec observáveis; nenhum comportamento de pulo, dash, estados, espinhos, peixeira, corte, câmera com suavização, animação ou som (estão fora do escopo desta fatia).
