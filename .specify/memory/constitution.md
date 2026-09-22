# Constituição do projeto Zé Peixeira

Regras válidas para todas as fatias. O agente não altera este arquivo. Mudanças são propostas ao humano, que decide.

## 1. Motor e linguagem

1.1. Godot **4.x** estável (versão exata registrada no `README.md`), GDScript com tipagem estática (`var x: float`, `func f() -> void`).

1.2. **APIs do Godot 3 são proibidas.** Na dúvida, consultar a documentação da versão 4. As trocas mais frequentes:

| Proibido (Godot 3) | Usar (Godot 4) |
|---|---|
| `KinematicBody2D` | `CharacterBody2D` |
| `move_and_slide(velocity, Vector2.UP)` | propriedade `velocity` + `move_and_slide()` sem argumentos |
| `yield(...)` | `await` |
| `export var` / `onready var` | `@export var` / `@onready var` |
| `connect("sinal", self, "_metodo")` | `sinal.connect(_metodo)` |
| `emit_signal("sinal")` | `sinal.emit()` |
| `TileMap` com camadas internas | `TileMapLayer` |
| `get_node("...")` em cadeia longa | `@onready var x := $Caminho` ou `%NomeUnico` |

1.3. Toda a lógica de movimento roda em `_physics_process(delta)`, com a física a **60 ticks por segundo** (padrão do projeto). Critérios de aceitação medidos em tempo podem ser convertidos em ticks (0,1 s = 6 ticks).

## 2. Arquitetura

2.1. **Regras de decisão em classes puras.** Decisões como "pode pular agora?" e "qual a nova velocidade horizontal?" ficam em classes que estendem `RefCounted`, em `game/scripts/regras/`, sem acesso a nós, física ou `Input`. Elas recebem o estado necessário por parâmetro e devolvem o resultado.

2.2. **O nó do jogador só orquestra.** Ele lê a entrada, consulta as regras, aplica `velocity` e chama `move_and_slide()`. Ele não contém números mágicos nem regras de decisão.

2.3. **Afinação em dados.** Todo parâmetro numérico de movimento fica no recurso `PlayerTuning` (`game/scripts/data/player_tuning.gd`, com `class_name PlayerTuning`), instanciado em `game/data/player_tuning.tres` e exposto ao jogador por `@export`. Valores literais no código de movimento são proibidos, exceto 0 e 1.

2.4. **Entrada por ações nomeadas.** Só se lê entrada por `Input` com as ações do mapa do projeto: `mover_esquerda`, `mover_direita`, `mover_cima`, `mover_baixo`, `pular`, `dash`, `arremessar`, `cortar`. Teclas ou botões diretos no código são proibidos. Cada ação tem mapeamento de teclado e de controle.

2.5. **Comunicação por sinais.** Um objeto do mundo (espinho, mandacaru, peixeira) não chama métodos do jogador diretamente: emite sinais ou é detectado por `Area2D`. Isso é o padrão Observer.

2.6. **Padrões nomeados.** Todo plano indica os padrões de *Game Programming Patterns* (Nystrom) usados e por quê. Não se introduz padrão sem necessidade demonstrada na spec.

## 3. Placeholders

3.1. Colisão e visual são nós separados. A forma de colisão tem dimensões próprias, definidas na cena, e nunca é derivada do tamanho do visual.

3.2. O visual é `ColorRect` ou `Polygon2D`, com as cores fixas abaixo (a legibilidade é requisito de jogo, não estética):

| Entidade | Cor | Forma |
|---|---|---|
| Zé | azul | retângulo 8×11 px |
| Terreno | cinza-escuro | retângulos |
| Espinhos | vermelho | triângulos |
| Mandacaru | verde | retângulo vertical |
| Peixeira | cinza-claro | retângulo fino |

3.3. Trocar o placeholder por um sprite não pode exigir mudança em script de regra ou de jogador.

3.4. Resolução de referência: 320×180, com `display/window/stretch/mode = viewport` e `display/window/stretch/scale_mode = integer`.

## 4. Testes

4.1. Framework: **GUT**, com os testes em `game/tests/test_NNN_*.gd` (um arquivo por fatia).

4.2. Cada requisito funcional (RF) da spec tem ao menos um teste. O nome do teste cita o identificador (`test_rf003_coyote_expira_apos_janela`).

4.3. Os testes exercitam as classes de `regras/` diretamente, simulando ticks. Testes que dependem de física real são exceção e ficam marcados.

4.4. Os testes de todas as fatias anteriores continuam passando. Uma fatia que quebra teste antigo não é aceita.

## 5. Processo

5.1. Uma tarefa por vez. O agente para ao terminar cada tarefa e resume o que mudou.

5.2. O agente não altera `spec.md` nem este arquivo. Se a implementação revelar um problema na spec, ele descreve o problema e aguarda a decisão.

5.3. Nada fora da seção *Fora do escopo* da spec ativa é implementado, mesmo que "seja rápido".

5.4. Nomes de classes, arquivos e métodos em português, sem acento (`regras_pulo.gd`, `pode_pular()`). Termos consagrados da API do Godot ficam como estão.
