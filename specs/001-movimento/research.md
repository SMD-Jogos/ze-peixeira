# Research: Movimento horizontal e gravidade (001-movimento)

## Decisão 1 — divergência entre o `deadzone` das ações em `project.godot` e o campo `zona_morta` do RF-001

**Decision**: `zona_morta` (0,2), aplicado dentro da classe pura `EntradaHorizontal` (`game/scripts/regras/entrada_horizontal.gd`), é o único mecanismo que decide o arredondamento de RF-001. O `deadzone` por ação em `game/project.godot` (atualmente 0,5, herdado do valor padrão usado ao criar o mapa de entrada no Passo 0/1) vai para **0,0** — decidido pelo humano na revisão deste plano — numa tarefa própria do `/speckit.tasks`, para que o Godot não descarte, antes mesmo de o jogo ler o valor, entradas analógicas entre 0,2 e 0,5 que a spec já decidiu que devem contar.

**Rationale**: são dois mecanismos em camadas diferentes.
- O `deadzone` do `InputMap` é um filtro do próprio motor: ele decide, antes do nosso código rodar, se um evento de eixo analógico (`InputEventJoypadMotion`) é reportado como "pressionado" com que força (`Input.get_action_strength`). Hoje ele não tem efeito prático porque as 8 ações só têm eventos digitais (teclas e botões de D-pad/face) mapeados — nenhum eixo analógico foi vinculado ainda (ver Passo 0/1).
- O `zona_morta` do RF-001 é uma regra do domínio do jogo (definida na spec, não no motor): decide como um valor analógico bruto vira −1/0/1 para a lógica de movimento, e é isso que a classe pura testa.
- Como hoje as ações são só digitais, não há conflito funcional imediato. O conflito é latente: se uma fatia futura vincular um eixo analógico a essas ações, o `deadzone` de 0,5 do motor filtraria (relataria força 0) qualquer coisa abaixo de 0,5 — maior que o `zona_morta` de 0,2 da spec — tornando o `zona_morta` de RF-001 morto para valores entre 0,2 e 0,5. Baixar o `deadzone` do motor para 0,0 (ou outro valor ≤ 0,2) garante que `zona_morta` seja de fato a única autoridade sobre esse limiar, como a spec decidiu.

**Alternatives considered**:
- Manter o `deadzone` do motor em 0,5 e ignorar a divergência: rejeitada, porque criaria um segundo limiar de fato mais restritivo que o decidido na spec, silenciosamente, só seria percebido quando/se um eixo analógico fosse de fato vinculado — o tipo de bug que passa despercebido até o playtest de outra fatia.
- Remover `zona_morta` da spec e confiar só no `deadzone` do motor: rejeitada — foi decisão explícita do humano manter `zona_morta` na tabela de Afinação do `PlayerTuning` (spec, Clarifications), e o `deadzone` do motor não é testável por GUT (é configuração de engine, não uma classe pura).

## Decisão 2 — como a cena representa "ponto inicial" e `limite_inferior_fase` (RF-006)

**Decision**: `game/scenes/fase_teste.tscn` tem um nó `Marker2D` chamado `PontoInicial` (posição lida em runtime por `$PontoInicial.position`) e um script de raiz `game/scripts/mundo/fase.gd` com `@export var limite_inferior_fase: float`, exportado no Inspector da cena.

**Rationale**: RF-006 e a decisão humana de revisão já dizem que os dois são "propriedade da cena", não do `PlayerTuning` — a spec deliberadamente não fixa como. `Marker2D` é o jeito idiomático do Godot 4 de marcar uma posição no editor sem custo de colisão ou visual; um `@export` no script raiz da fase deixa `limite_inferior_fase` visível e ajustável no Inspector por cena, sem precisar mexer em código — coerente com a separação regra/afinação da constituição (seção 4 do `docs/fluxo-sdd.md`), mesmo `limite_inferior_fase` não sendo, tecnicamente, campo do `PlayerTuning`.

**Alternatives considered**:
- Codificar `limite_inferior_fase` como constante no script do jogador: rejeitada — violaria a constituição 2.2 (nó não tem número mágico) e a própria spec, que diz explicitamente que é propriedade da cena.
- Usar a posição de outro nó existente (ex.: o próprio `CharacterBody2D` colocado na cena) como "ponto inicial", sem um marcador dedicado: rejeitada — acopla a posição inicial à posição de edição do jogador na cena, dificultando o playtest (mover o marcador não deveria exigir mover o nó do jogador em si) e não deixa claro, para quem lê a cena, qual é o ponto de respawn.
