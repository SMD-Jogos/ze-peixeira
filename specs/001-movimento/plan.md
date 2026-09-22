# Implementation Plan: Movimento horizontal e gravidade

**Branch**: main (sem branch por fatia) | **Date**: 2026-09-22 | **Spec**: [specs/001-movimento/spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-movimento/spec.md`

## Summary

O Zé corre com aceleração/desaceleração, cai com gravidade e é contido pelo terreno. A abordagem: um nó `CharacterBody2D` que só orquestra (lê `Input`, chama classes puras, aplica `velocity`, chama `move_and_slide()`), com toda a lógica de decisão isolada em classes `RefCounted` sob `game/scripts/regras/`, testáveis sem a física do motor.

## Technical Context

**Language/Version**: GDScript com tipagem estática, Godot 4.7.2 (estável)

**Primary Dependencies**: Godot 4 (`CharacterBody2D`, `move_and_slide()`); GUT 9.7.1 para testes

**Storage**: N/A — afinação em `Resource` (`.tres`), não é dado persistente de usuário

**Testing**: GUT, rodado headless: `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`; testes exercitam as classes de `game/scripts/regras/` diretamente (constituição 4.3), não a cena completa

**Target Platform**: Godot 4, desktop — sem preset de exportação definido nesta fatia

**Project Type**: jogo single-player, projeto único em `game/`

**Performance Goals**: física fixa a 60 ticks/s (padrão do motor Godot 4 — não precisa de override em `project.godot`, ver constituição 1.3)

**Constraints**: resolução de referência 320×180 (`stretch/mode=viewport`, `scale_mode=integer`); a fase de teste cabe inteira na tela, câmera fixa sem seguir o jogador (decisão do clarify, RF-007); nenhuma API do Godot 3 (constituição 1.2)

**Scale/Scope**: uma fase de teste, um jogador; pulo, dash, máquina de estados, espinhos, peixeira, corte, câmera com suavização, animações e som ficam fora do escopo (spec, seção "Fora do escopo")

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Regra | Como esta fatia cumpre |
|---|---|
| 1.1–1.2 Godot 4.x, GDScript tipado, sem API do Godot 3 | `CharacterBody2D` + `velocity`/`move_and_slide()` sem argumentos; `@export`/`@onready`; nenhuma API listada como proibida é usada |
| 1.3 Física a 60 ticks/s | Valor padrão do motor — confirmado em `game/project.godot` (não precisou de override; ver Passo 0/1) |
| 2.1 Regras em classes puras (`RefCounted`, sem nó/física/`Input`) | 5 classes em `game/scripts/regras/` (ver Project Structure); recebem `no_chao` e os valores de `PlayerTuning` por parâmetro |
| 2.2 Nó só orquestra | `jogador.gd` lê `Input`, chama as regras, aplica `velocity`, chama `move_and_slide()`; nenhum número mágico ou decisão no nó. `fase.gd` também só orquestra: consulta `RegraReaparecimento` e chama `jogador.reaparecer()`, sem acessar nós internos do jogador nem decidir a lógica de reaparecimento |
| 2.3 Afinação em dados | `PlayerTuning` (`game/scripts/data/player_tuning.gd`) ganha o campo `zona_morta` (decisão humana pós-clarify); nenhum literal de movimento fora do recurso |
| 2.4 Entrada por ações nomeadas | Só `mover_esquerda`/`mover_direita` são lidas nesta fatia; `mover_cima`/`mover_baixo`/`pular`/`dash`/`arremessar`/`cortar` existem no mapa (Passo 0/1) mas não são lidas — reservadas para fatias futuras |
| 2.5 Comunicação por sinais | Não se aplica nesta fatia: não há objeto de mundo (espinho, mandacaru, peixeira — todos fora do escopo). A colisão com parede é resolvida pelo `move_and_slide()` do próprio motor, sem sinal customizado |
| 2.6 Padrões nomeados | Ver "Padrões de projeto (Nystrom)" abaixo |
| 3.1–3.4 Placeholders | Cena do jogador com `CollisionShape2D` e `ColorRect` (8×11, azul) separados; terreno em retângulos cinza-escuro; resolução/stretch já configurados |
| 4.1–4.4 Testes | Ver "Estratégia de testes" abaixo |
| 5.1–5.4 Processo | Uma tarefa por vez fica a cargo do `/speckit.tasks` + `/speckit.implement`; nomes em português sem acento (`regras_entrada.gd` → ver nomes reais abaixo, todos seguem a convenção) |

Nenhuma violação identificada — tabela de Complexity Tracking fica vazia.

## Project Structure

### Documentation (this feature)

```text
specs/001-movimento/
├── plan.md              # este arquivo
├── research.md          # Fase 0 (zona morta vs. deadzone; ponto inicial/limite na cena)
├── data-model.md        # Fase 1 (PlayerTuning, Jogador, Fase)
├── quickstart.md        # Fase 1 (validação manual + automatizada)
└── tasks.md             # Fase 2 (/speckit.tasks — ainda não gerado)
```

Não foi gerado `contracts/`: o projeto não expõe nenhuma interface externa (API, CLI, protocolo) — é uma cena jogável autocontida.

### Source Code (repository root)

```text
game/
├── project.godot
├── scenes/
│   ├── jogador.tscn                  # CharacterBody2D + CollisionShape2D + ColorRect (placeholder)
│   └── fase_teste.tscn               # RF-007: chão, 2 plataformas, parede, vão; Marker2D "PontoInicial"; Camera2D fixa
├── scripts/
│   ├── jogador/
│   │   └── jogador.gd                # nó, só orquestra (constituição 2.2)
│   ├── regras/
│   │   ├── entrada_horizontal.gd     # RF-001
│   │   ├── movimento_horizontal.gd   # RF-002, RF-003 (CS-001, CS-002)
│   │   ├── queda.gd                  # RF-004 (CS-003)
│   │   ├── direcao_olhar.gd          # RF-005 (Cenário 3) — recebe a entrada já discretizada por EntradaHorizontal, nunca o valor bruto
│   │   └── reaparecimento.gd         # RF-006, RF-008 (renomeado de respawn.gd/RegraRespawn — achado C1 do /speckit.analyze, constituição 5.4)
│   ├── data/
│   │   └── player_tuning.gd          # class_name PlayerTuning (inclui zona_morta)
│   └── mundo/
│       └── fase.gd                   # @export limite_inferior_fase; ponto inicial via Marker2D; orquestra o reaparecimento (decisão do humano — ver abaixo)
├── data/
│   └── player_tuning.tres            # instância de PlayerTuning
└── tests/
    └── test_001_movimento.gd         # gerado no /speckit.tasks + /speckit.implement, não neste plano
```

**Structure Decision**: projeto único (`game/`), sem separação backend/frontend — é um jogo Godot. A separação relevante é a da constituição (regras puras vs. nó de orquestração vs. dados de afinação), não uma estrutura de camadas de aplicação.

**Ordem de composição em `jogador.gd` (`_physics_process`)**: `jogador.gd` lê o valor bruto de `Input`, chama `EntradaHorizontal.arredondar(bruto, tuning.zona_morta)` primeiro, e só então passa o resultado já discretizado (−1/0/1) para `MovimentoHorizontal.atualizar_velocidade` **e** para `DirecaoOlhar.atualizar`. `DirecaoOlhar` nunca recebe o valor bruto do analógico — evita que a classe de direção do olhar precise repetir a lógica de zona morta do RF-001, e mantém cada regra com uma única responsabilidade.

**Direção do olhar é só visual, nunca no corpo físico** (decisão do humano): a transformação de direção (ex.: `scale.x`) é aplicada apenas no nó visual (`ColorRect`), filho do `CharacterBody2D` — nunca no `CharacterBody2D` em si, porque escala negativa num corpo físico espelharia também a `CollisionShape2D` (constituição 3.1: a colisão tem forma própria, não derivada do visual). O placeholder do Zé ganha um "olho" (retângulo pequeno e escuro, 2×2 px), filho do nó visual, para que a mudança de direção seja observável mesmo com o retângulo principal sendo simétrico.

**Reaparecimento é orquestrado por `fase.gd`, não por `jogador.gd`** (decisão do humano, invertendo o desenho inicial deste plano): a cada tick, `fase.gd` consulta `RegraReaparecimento.deve_reaparecer` com o `global_position.y` do Zé e seu próprio `limite_inferior_fase`; se verdadeiro, chama `jogador.reaparecer(posicao: Vector2)`. `jogador.gd` expõe esse método (zera `velocity`, define `direcao_olhar = 1`, aplica a posição recebida) e não acessa nenhum nó da fase — só recebe a posição já resolvida por parâmetro. O `_ready()` de `fase.gd` chama o mesmo `jogador.reaparecer()` para cobrir o RF-008 no início da fase. `global_position` é usado dos dois lados (nunca `position` local), já que `jogador.tscn` é instanciado dentro de `fase_teste.tscn`.

## Padrões de projeto (Nystrom)

**Usados nesta fatia:**

- **Update Method** — `jogador.gd` implementa `_physics_process(delta)`: a cada tick fixo, lê a entrada, chama as regras puras e aplica o resultado. É o padrão clássico de "cada objeto ativo se atualiza a cada iteração do loop", aqui restrito ao único objeto ativo desta fatia (o jogador).
- **Game Loop** — fornecido pelo próprio motor (o loop de física de 60 Hz do Godot). Não é implementado por nós; é citado porque é a infraestrutura sobre a qual o Update Method roda, e a constituição pede que a origem de cada padrão seja explícita.

**Não usados nesta fatia, e por quê:**

- **State** — adiado para a fatia `003-maquina-de-estados`, que existe justamente para refatorar o controlador (que aqui ainda tem poucos ramos condicionais em RF-002/RF-003) para estados explícitos. Introduzir State agora seria padrão sem necessidade demonstrada (constituição 2.6).
- **Observer** — reservado para quando existir um objeto de mundo que precise notificar o jogador sem chamada direta (constituição 2.5) — a partir da fatia `004-dash-gibao` (espinhos) e seguintes. Esta fatia não tem nenhum objeto desse tipo; a colisão com parede é resolvida pelo `move_and_slide()` nativo, sem sinal.
- **Component** — sem necessidade de composição dinâmica de comportamento nesta fatia; relevante a partir da peixeira/corte (fatias 005/006).
- **Command** — não usado em nenhuma fatia do projeto (fluxo-sdd.md, seção 7): nenhuma mecânica do Zé Peixeira precisa de reexecução ou desfazer.

## Estratégia de testes (GUT)

Por constituição 4.3, os testes exercitam as classes de `game/scripts/regras/` **diretamente**, simulando ticks e recebendo `no_chao` como parâmetro — não dependem da física real nem da cena completa. Convenção de nome por constituição 4.1/4.2: `game/tests/test_001_movimento.gd`, com o identificador do requisito no nome de cada teste.

Os testes simulam ticks com `delta = 1.0 / 60.0` e comparam velocidades com `assert_almost_eq` (tolerância — os valores intermediários envolvem ponto flutuante, ex.: 16,7, 33,3, 83,3 px/s). Igualdade exata (`assert_eq`) só é usada onde a própria regra garante um valor exato "redondo": a velocidade em `corrida_max` no tick 6 (CS-001) e a velocidade zero no tick 6 da frenagem (CS-002) — a "aproximação nunca ultrapassa o alvo" (RF-002) é precisamente o que torna esses dois pontos exatos, não aproximados.

O `before_each()` de `game/tests/test_001_movimento.gd` constrói um `PlayerTuning.new()` e atribui os 7 campos manualmente com os valores de partida da spec — **nunca** carrega `game/data/player_tuning.tres` — para que ajustes de playtest no `.tres` não quebrem os testes.

| RF/CS | Classe exercitada | Testes (nomes definidos no `/speckit.tasks`) |
|---|---|---|
| RF-001 | `EntradaHorizontal.arredondar` | `test_rf001_abaixo_da_zona_morta_vira_zero`, `test_rf001_acima_da_zona_morta_arredonda_para_sinal`, `test_rf001_ambas_direcoes_resultam_zero` |
| RF-002, CS-001, CS-002 | `MovimentoHorizontal.atualizar_velocidade` | `test_rf002_acelera_ate_corrida_max`, `test_rf002_reduz_com_corrida_reducao_acima_do_maximo`, `test_cs001_atinge_corrida_max_no_tick_6`, `test_cs002_para_no_tick_6_sem_trocar_sinal` |
| RF-003 | `MovimentoHorizontal.atualizar_velocidade` (com `no_chao = false`) | `test_rf003_multiplicador_ar_reduz_taxa` |
| RF-004, CS-003 | `Queda.atualizar_velocidade_vertical` | `test_rf004_gravidade_acumula_por_tick`, `test_cs003_nunca_ultrapassa_queda_max` |
| RF-005 (Cenário 3) | `DirecaoOlhar.atualizar` | `test_rf005_muda_no_tick_em_que_a_entrada_muda_de_sinal`, `test_rf005_mantem_direcao_com_entrada_zero` |
| RF-006, RF-008 | `RegraReaparecimento.deve_reaparecer` | `test_rf006_reaparece_abaixo_do_limite`, `test_rf008_estado_apos_reaparecer_e_no_inicio` |
| RF-007 | — (é layout de cena, não regra pura) | Verificado no playtest manual (`quickstart.md`), não por teste GUT |
| CS-004 | — (é uma verificação de convenção, não uma regra) | Conferido na revisão humana do diff: todo RF acima tem teste com o identificador no nome |

## Complexity Tracking

Nenhuma violação da constituição identificada nesta fatia — tabela vazia por design.
