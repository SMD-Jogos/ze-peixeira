# Tasks: Movimento horizontal e gravidade (001-movimento)

**Input**: Design documents de `specs/001-movimento/` (`plan.md`, `spec.md`, `research.md`, `data-model.md`, `quickstart.md`)

**Tests**: incluídos — a spec exige teste GUT para cada RF (CS-004) e a constituição (4.1–4.4) torna teste obrigatório, não opcional.

**Organização**: esta fatia não tem "user stories" com prioridade (P1/P2/P3) — `spec.md` descreve um único incremento coeso (RF-001 a RF-008, CS-001 a CS-004). Por pedido explícito do humano, as tarefas seguem uma trilha linear, não fases por user story: T001 monta a cena base; cada tarefa seguinte entrega uma regra (ou uma peça pequena e isolada) com seu teste GUT e um efeito visível no jogo rodando, terminando com os testes passando. Por isso nenhuma tarefa usa o marcador `[Story]` do formato padrão — não há user story para citar.

## Format: `[ID] [P?] Description com caminho de arquivo`

- **[P]**: pode, em tese, rodar em paralelo (arquivos diferentes, sem dependência) — mas o processo desta demonstração serializa uma tarefa por vez de qualquer forma (constituição 5.1; `docs/fluxo-sdd.md`, Passo 6). O marcador documenta independência teórica, não uma instrução para paralelizar.

---

## Phase 1: Setup

**Purpose**: cena jogável mínima, sem nenhuma regra ainda.

- [ ] T001 Criar `game/scenes/fase_teste.tscn`: chão plano, duas plataformas em alturas diferentes, uma parede, um vão (RF-007); um nó `Marker2D` chamado `PontoInicial`; uma `Camera2D` fixa enquadrando a fase inteira em 320×180 (RF-007, decisão do clarify). Criar `game/scenes/jogador.tscn`: `CharacterBody2D` com `CollisionShape2D` (forma própria, não derivada do visual) e um `ColorRect` azul de 8×11 px como placeholder (constituição 3.1–3.2), parado, sem nenhum script de regra ainda. Instanciar `jogador.tscn` em `fase_teste.tscn`, na posição de `PontoInicial`. Marcar `fase_teste.tscn` como cena principal em `game/project.godot` (`run/main_scene`). **Fim**: `F5` abre a fase e o Zé aparece parado, azul, sobre o chão.

**Checkpoint**: cena roda, sem nenhuma regra de movimento ainda.

---

## Phase 2: Foundational (bloqueia as regras seguintes)

**Purpose**: dado de afinação que quase toda regra vai receber por parâmetro.

- [ ] T002 [P] Criar `game/scripts/data/player_tuning.gd` (`class_name PlayerTuning`, `extends Resource`) com os 7 campos `@export` da tabela de Afinação da spec (`corrida_max`, `corrida_aceleracao`, `corrida_reducao`, `multiplicador_ar`, `gravidade`, `queda_max`, `zona_morta`). Criar `game/data/player_tuning.tres`, instância de `PlayerTuning` com os valores de partida da spec. Criar `game/scripts/jogador/jogador.gd` — nesta tarefa, mínimo: `extends CharacterBody2D` e `@export var tuning: PlayerTuning`, sem nenhuma lógica de movimento ainda — e associá-lo ao nó raiz de `game/scenes/jogador.tscn`. **Fim**: o jogo continua rodando igual à T001 (não há regra consumindo o tuning ainda); nenhum teste novo (não há regra para testar).

**Checkpoint**: dado de afinação disponível; nenhuma regra ainda depende dele em runtime.

---

## Phase 3: Regras de movimento (uma por tarefa)

**Goal**: cada tarefa entrega uma regra pura (`game/scripts/regras/`) com teste GUT em `game/tests/test_001_movimento.gd` e um efeito observável ao rodar o jogo.

- [ ] T003 Entrada horizontal e corrida (RF-001, RF-002, CS-001, CS-002). Criar `game/scripts/regras/entrada_horizontal.gd` (`class_name EntradaHorizontal extends RefCounted`, método que arredonda o valor bruto de `Input.get_axis("mover_esquerda","mover_direita")` para −1/0/1 usando `tuning.zona_morta`) e `game/scripts/regras/movimento_horizontal.gd` (`class_name MovimentoHorizontal extends RefCounted`, método que recebe `velocidade_atual`, `entrada` (já discretizada), `no_chao`, `delta`, `tuning` e devolve a nova velocidade horizontal, implementando os dois ramos do RF-002 — `corrida_reducao` quando acima do alvo no mesmo sentido, `corrida_aceleracao` nos demais casos). Nesta tarefa, `no_chao` ainda não altera a taxa (RF-003 fica para T006). Em `jogador.gd`, no `_physics_process`, ler o eixo bruto, chamar `EntradaHorizontal.arredondar`, depois `MovimentoHorizontal.atualizar_velocidade`, aplicar em `velocity.x` e chamar `move_and_slide()`. O `before_each()` de `game/tests/test_001_movimento.gd` constrói um `PlayerTuning.new()` e atribui os 7 campos manualmente com os valores de partida da spec — **não** carrega `player_tuning.tres` — para que ajustes de playtest no `.tres` não quebrem os testes (mesma regra registrada em `plan.md`, "Estratégia de testes"). Testes, com `delta = 1.0/60.0` e `assert_almost_eq` (exceto os pontos exatos do tick 6 — ver `plan.md`): `test_rf001_abaixo_da_zona_morta_vira_zero`, `test_rf001_acima_da_zona_morta_arredonda_para_sinal`, `test_rf001_ambas_direcoes_resultam_zero` (achado E2 do `/speckit.analyze`: `mover_esquerda` e `mover_direita` juntas → entrada 0), `test_rf002_acelera_ate_corrida_max`, `test_rf002_reduz_com_corrida_reducao_acima_do_maximo` (achado E1: ramo `corrida_reducao` do RF-002, documentado em Casos-limite e ainda sem teste), `test_cs001_atinge_corrida_max_no_tick_6`, `test_cs002_para_no_tick_6_sem_trocar_sinal`. **Fim**: segurar `mover_direita`/`mover_esquerda` move o Zé na cena; testes passando.

- [ ] T004 [P] Zona morta do `InputMap` (RF-001, decisão humana — `research.md`, Decisão 1). Em `game/project.godot`, reduzir o campo `"deadzone"` das 8 ações de entrada de 0,5 para 0,0, para que o filtro do próprio motor não conflite com o `zona_morta` de 0,2 aplicado em `EntradaHorizontal` (T003). Sem teste GUT novo (é configuração de engine, não uma classe pura — constituição 4.3). **Fim**: jogo roda igual à T003; `game/project.godot` com `"deadzone": 0.0` nas 8 ações.

- [ ] T005 Queda e gravidade (RF-004, CS-003). Criar `game/scripts/regras/queda.gd` (`class_name Queda extends RefCounted`, método que recebe `velocidade_vertical_atual`, `delta`, `tuning` e devolve a nova velocidade vertical, somando `gravidade × delta` até o limite `queda_max`). Em `jogador.gd`, chamar essa regra a cada tick e aplicar em `velocity.y` antes de `move_and_slide()`. Testes: `test_rf004_gravidade_acumula_por_tick`, `test_cs003_nunca_ultrapassa_queda_max`. **Fim**: andar para fora de uma plataforma faz o Zé cair (antes desta tarefa, ele ficava "flutuando" ao sair da borda); testes passando.

- [ ] T006 Multiplicador no ar (RF-003). Estender `game/scripts/regras/movimento_horizontal.gd`: quando `no_chao = false`, multiplicar as taxas de RF-002 (`corrida_aceleracao`/`corrida_reducao`) por `tuning.multiplicador_ar`. Em `jogador.gd`, passar `is_on_floor()` como `no_chao` (constituição 2.1 — a leitura de física fica no nó; a classe pura só recebe o booleano). Teste: `test_rf003_multiplicador_ar_reduz_taxa`. **Fim**: no ar, o Zé acelera/inverte visivelmente mais devagar do que no chão; testes passando.

- [ ] T007 Direção do olhar (RF-005, Cenário 3). Criar `game/scripts/regras/direcao_olhar.gd` (`class_name DirecaoOlhar extends RefCounted`, método que recebe a direção atual e a entrada **já discretizada** por `EntradaHorizontal` — nunca o valor bruto — e devolve a nova direção: muda apenas quando a entrada é diferente de zero). Em `jogador.gd`, manter `direcao_olhar: int` (inicial 1, direita — RF-005), atualizado no mesmo tick em que a entrada muda de sinal, antes do resultado de `MovimentoHorizontal` terminar de inverter a velocidade (Cenário 3). A transformação visual correspondente (ex.: `scale.x`) é aplicada **só no nó visual** (o `ColorRect`, filho do `CharacterBody2D`), **nunca no `CharacterBody2D`**: escala negativa no corpo físico espelharia também a colisão (constituição 3.1, colisão não deriva do visual). **Decisão do humano**: acrescentar ao placeholder do Zé um retângulo pequeno e escuro ("olho", 2×2 px), filho do nó visual, posicionado no lado para onde o Zé olha, para que o Cenário 3 seja observável mesmo com o retângulo principal sendo simétrico. Testes: `test_rf005_muda_no_tick_em_que_a_entrada_muda_de_sinal`, `test_rf005_mantem_direcao_com_entrada_zero` (achado B1 do `/speckit.analyze`: a direção não muda quando a entrada volta a 0). **Fim**: o "olho" troca de lado no tick em que a entrada muda de sinal; testes passando.

- [ ] T008 Limite inferior e reaparecimento (RF-006, RF-008). Criar `game/scripts/mundo/fase.gd` (script raiz de `fase_teste.tscn`, `@export var limite_inferior_fase: float`, abaixo da borda inferior da tela — `research.md`, Decisão 2) e `game/scripts/regras/reaparecimento.gd` (`class_name RegraReaparecimento extends RefCounted`, método `deve_reaparecer(y: float, limite: float) -> bool`; renomeado de `RegraRespawn`/`respawn.gd` — achado C1 do `/speckit.analyze`, constituição 5.4). **Responsabilidade invertida** (decisão do humano): é `fase.gd` quem orquestra, não `jogador.gd`. A cada tick, `fase.gd` chama `RegraReaparecimento.deve_reaparecer` com o `global_position.y` do Zé e seu próprio `limite_inferior_fase`; se verdadeiro, chama `jogador.reaparecer($PontoInicial.global_position)`. `jogador.gd` expõe um método `reaparecer(posicao: Vector2)` (zera `velocity`, define `direcao_olhar = 1`, aplica `posicao` a `global_position`) e **não acessa nenhum nó da fase** — só recebe a posição pronta por parâmetro. O `_ready()` de `fase.gd` chama o mesmo `jogador.reaparecer($PontoInicial.global_position)` para cobrir o RF-008 também no início da fase. Usar `global_position` dos dois lados (nunca `position` local). Testes: `test_rf006_reaparece_abaixo_do_limite`, `test_rf008_estado_apos_reaparecer_e_no_inicio`. **Fim**: cair no vão da fase teleporta o Zé de volta ao `PontoInicial`, parado, olhando para a direita; testes passando.

**Checkpoint**: todos os RF-001 a RF-008 implementados e testados; jogo jogável do início ao fim dos 7 cenários de aceitação da spec.

---

## Phase 4: Polish

- [ ] T009 Rodar a validação manual completa de `quickstart.md` (os 9 passos, incluindo o Cenário 6 — colisão com parede — que não tem regra pura própria: é resolvido pelo `move_and_slide()` do motor contra o `StaticBody2D` da parede criado na T001).
- [ ] T010 [P] Conferir CS-004: cada RF-001 a RF-008 tem ao menos um teste em `game/tests/test_001_movimento.gd` com o identificador no nome (checklist de revisão humana, `docs/checklists/revisao-tarefa.md`).

---

## Dependencies & Execution Order

- T001 (Setup) → sem dependências, primeira tarefa.
- T002 (Foundational) → depende de T001 (precisa da cena e do nó do jogador para referenciar `tuning`); bloqueia T003 em diante.
- T003 → depende de T002. T004 → depende conceitualmente de T003 (só faz sentido depois que a entrada é lida), mas mexe só em `game/project.godot`, sem sobrepor arquivo com T003.
- T005 → depende de T003 (usa a mesma malha de `_physics_process` em `jogador.gd`).
- T006 → depende de T003 e T005 (precisa de `no_chao`, que só faz diferença observável depois que há queda).
- T007 → depende de T003 (consome a saída já discretizada de `EntradaHorizontal`).
- T008 → depende de T005 (precisa de queda para o Zé cair no vão) e de T001 (usa `PontoInicial` e a estrutura da fase).
- T009, T010 → depois de T003–T008 completas.

## Parallel Opportunities

- T002 poderia, em tese, começar em paralelo a partes finais de T001 (arquivos diferentes). T004 não sobrepõe arquivo com nenhuma tarefa de regra. Na prática, este projeto roda uma tarefa por vez, com aprovação humana entre cada uma (constituição 5.1) — os marcadores `[P]` são só documentação de independência de arquivo.

## Implementation Strategy

Incremental, uma tarefa por vez, cada uma terminando com o jogo rodando e (a partir da T003) os testes passando — sem MVP parcial "por user story", já que a fatia inteira é o incremento mínimo desta demonstração. Parar e validar com `docs/checklists/revisao-tarefa.md` depois de cada tarefa, antes do commit (`docs/fluxo-sdd.md`, Passo 6).
