# Data Model: Movimento horizontal e gravidade (001-movimento)

## `PlayerTuning` (Resource)

`game/scripts/data/player_tuning.gd`, `class_name PlayerTuning`, instanciado em `game/data/player_tuning.tres`. Todos os campos são `@export`, sem lógica — só dados (constituição 2.3).

| Campo | Tipo | Unidade | Fonte (spec) |
|---|---|---|---|
| `corrida_max` | `float` | px/s | Afinação |
| `corrida_aceleracao` | `float` | px/s² | Afinação |
| `corrida_reducao` | `float` | px/s² | Afinação |
| `multiplicador_ar` | `float` | adimensional (0–1) | Afinação |
| `gravidade` | `float` | px/s² | Afinação |
| `queda_max` | `float` | px/s | Afinação |
| `zona_morta` | `float` | adimensional (0–1) | Afinação (RF-001, decisão humana pós-clarify) |

Sem relações com outros recursos; sem transições de estado (é um `Resource` de dados puro).

## `Jogador` (estado em runtime, não persistido)

Representado pelas propriedades do nó `game/scripts/jogador/jogador.gd` (`CharacterBody2D`). Não é uma entidade de dados salva em arquivo — listada aqui porque o comportamento da spec depende do seu estado a cada tick.

| Propriedade | Tipo | Regra que a atualiza | Requisitos |
|---|---|---|---|
| `velocity.x` | `float` (herdado de `CharacterBody2D`) | `MovimentoHorizontal.atualizar_velocidade` | RF-002, RF-003, CS-001, CS-002 |
| `velocity.y` | `float` (herdado) | `Queda.atualizar_velocidade_vertical` | RF-004, CS-003 |
| `direcao_olhar` | `int` (−1 ou 1) | `DirecaoOlhar.atualizar` | RF-005 (Cenário 3), RF-008 |
| posição (`global_position`) | `Vector2` (herdado) | `move_and_slide()` (motor); resetada por `jogador.reaparecer(posicao)`, chamado por `fase.gd` (que consulta `RegraReaparecimento`) — o jogador não acessa nós da fase | RF-006, RF-007, RF-008 |
| `no_chao` | `bool`, lido de `is_on_floor()` pelo nó, passado por parâmetro às regras | não é atualizado por regra pura — é consultado pelo nó e repassado | RF-003, RF-008 |

Estado inicial (RF-008): `velocity = Vector2.ZERO`, `direcao_olhar = 1` (direita), posição = `PontoInicial.global_position` — aplicado por `jogador.reaparecer()`, chamado tanto no `_ready()` de `fase.gd` (início da fase) quanto quando `RegraReaparecimento.deve_reaparecer` for verdadeiro (queda abaixo do limite).

## `Fase` (propriedade da cena, não recurso de dados)

`game/scripts/mundo/fase.gd`, script raiz de `game/scenes/fase_teste.tscn`.

| Propriedade | Tipo | Fonte |
|---|---|---|
| `limite_inferior_fase` | `float`, `@export` | RF-006, decisão humana (research.md, Decisão 2) |
| ponto inicial | posição do nó filho `Marker2D` chamado `PontoInicial` | RF-006, RF-008, decisão humana (research.md, Decisão 2) |

Sem outras entidades nesta fatia — espinhos, mandacaru e peixeira estão fora do escopo (spec, "Fora do escopo").
