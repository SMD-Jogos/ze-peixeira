# Fatia 001 — Movimento horizontal e gravidade

**Status:** especificação escrita pelo humano · **Depende de:** nenhuma

## Objetivo

O Zé corre para os lados com aceleração e desaceleração perceptíveis, cai com gravidade e é contido pelo terreno. É a base sobre a qual as outras fatias se apoiam.

## Clarifications

### Session 2026-09-22

- Q: Depois que o Zé cai abaixo do limite inferior da fase e volta ao ponto inicial (RF-006), a direção que ele passa a olhar (RF-005) volta a ser "direita" (o padrão inicial), ou permanece a última direção em que ele estava olhando antes de cair? → A: Reseta para "direita" (mesmo estado inicial do RF-005).
- Q: No início da fase (ou depois de um respawn), o Zé já começa apoiado no chão, ou é posicionado no ar e cai até tocar o chão? → A: Começa (e reaparece) já apoiado no chão, parado, olhando para a direita.
- Q: Nas fórmulas de CS-001 e CS-002, o tick em que a entrada passa a ser lida conta como tick 1, ou a contagem começa do tick seguinte? → A: O tick em que a entrada é lida pela primeira vez é o tick 1 e já altera a velocidade.
- Q: RF-001 diz que a entrada analógica é "arredondada" para −1, 0 ou 1 — existe uma zona morta abaixo da qual conta como 0, ou qualquer valor ≠ 0 já vira −1 ou 1? → A: Existe zona morta de 0,2: abaixo disso (valor absoluto), a entrada conta como 0.
- Q: A fase de teste do RF-007 precisa caber inteira em 320×180 (câmera fixa, sem seguir o jogador), ou a câmera fixa só significa "sem suavização", podendo a fase ser maior que a tela? → A: A fase cabe inteira em 320×180; a câmera não se move.

### Decisão do humano (revisão) 2026-09-22

- D: RF-005 confirmado — o olhar segue a entrada, não a velocidade. Explicitado no Cenário 3: a direção do olhar muda no tick em que a entrada muda de sinal, antes de a velocidade terminar de inverter.
- D: RF-006 — cada fase define seu próprio ponto inicial e seu `limite_inferior_fase` (abaixo da borda inferior da tela visível). Como esses dois pontos são representados na cena é decisão do `/speckit.plan`, não desta spec.
- D: RF-001 — o valor da zona morta (0,2) foi movido para a tabela de Afinação como campo `zona_morta`; o RF-001 passa a citar o campo em vez do valor literal.

## Cenários de aceitação

1. **Dado** o Zé parado no chão, **quando** o jogador segura `mover_direita`, **então** ele acelera até a velocidade máxima de corrida e a mantém enquanto a ação estiver pressionada.
2. **Dado** o Zé correndo, **quando** o jogador solta a direção, **então** ele desacelera até parar, sem inverter o sentido.
3. **Dado** o Zé correndo para a direita, **quando** o jogador passa a segurar `mover_esquerda`, **então** ele desacelera, inverte e acelera para a esquerda; a direção do olhar já muda para a esquerda no tick em que a entrada muda de sinal, antes de a velocidade terminar de inverter.
4. **Dado** o Zé no ar, **quando** o jogador segura uma direção, **então** ele acelera mais devagar do que no chão.
5. **Dado** o Zé sem chão embaixo, **então** ele cai com aceleração constante até uma velocidade máxima de queda.
6. **Dado** o Zé correndo em direção a uma parede, **quando** encosta nela, **então** para na horizontal e não a atravessa.
7. **Dado** o Zé na fase, **quando** cai abaixo do limite inferior da fase, **então** volta ao ponto inicial, parado.

## Casos-limite

- `mover_esquerda` e `mover_direita` pressionadas juntas: a entrada horizontal é 0.
- Velocidade horizontal acima da máxima no mesmo sentido da entrada (possível em fatias futuras, como o dash): reduz com a taxa `corrida_reducao`, mais suave, e não é cortada de uma vez.

## Requisitos funcionais

- **RF-001** A entrada horizontal é discreta: −1, 0 ou 1 (direita menos esquerda). Entrada analógica é arredondada para esses valores com a zona morta `zona_morta` (ver Afinação): abaixo desse limiar em valor absoluto, a entrada conta como 0; a partir dele, arredonda para o sinal (−1 ou 1).
- **RF-002** A cada tick, a velocidade horizontal se aproxima do alvo `entrada × corrida_max`:
  - com taxa `corrida_reducao` quando |v| > `corrida_max` e o sentido de v é o mesmo da entrada;
  - com taxa `corrida_aceleracao` em todos os outros casos, inclusive com entrada 0 (frear usa a mesma taxa de acelerar).
  - A aproximação nunca ultrapassa o alvo.
- **RF-003** No ar, as taxas do RF-002 são multiplicadas por `multiplicador_ar`.
- **RF-004** A gravidade soma `gravidade × delta` à velocidade vertical a cada tick, até o limite `queda_max`.
- **RF-005** A direção do olhar é o sinal da última entrada horizontal diferente de 0. No início, o Zé olha para a direita.
- **RF-006** Cada fase define seu próprio ponto inicial e seu `limite_inferior_fase` (em pixels, no eixo y, abaixo da borda inferior da tela visível; propriedade da cena, não do `PlayerTuning`). Como esses dois pontos são representados na cena é decisão do plano, não desta spec. Ao cair abaixo de `limite_inferior_fase`, o Zé volta ao ponto inicial com velocidade zero e direção do olhar igual à direita (mesmo estado inicial do RF-005/RF-008).
- **RF-007** Existe uma fase de teste com chão plano, duas plataformas em alturas diferentes, uma parede e um vão por onde se pode cair. A fase inteira cabe na tela de 320×180; a câmera não se move.
- **RF-008** No início da fase, e sempre que o Zé reaparecer por efeito do RF-006, ele está parado, apoiado no chão e olhando para a direita.

## Afinação (valores de partida)

Ficam no recurso `PlayerTuning`, não no código. Unidades em pixels e segundos, para a resolução de 320×180. Os valores são inspirados no `Player.cs` de *Celeste* e servem de ponto de partida para o playtest.

| Campo | Valor |
|---|---|
| `corrida_max` | 90 px/s |
| `corrida_aceleracao` | 1000 px/s² |
| `corrida_reducao` | 400 px/s² |
| `multiplicador_ar` | 0,65 |
| `gravidade` | 900 px/s² |
| `queda_max` | 160 px/s |
| `zona_morta` | 0,2 |

## Fora do escopo

Pulo, dash, máquina de estados, espinhos, peixeira, câmera com suavização (a câmera é fixa na fase), animações, som.

## Critérios de sucesso

- **CS-001** Partindo do repouso no chão, com entrada constante a partir do tick 1 (o tick em que a entrada passa a ser lida já atualiza a velocidade nesse mesmo tick), o Zé atinge `corrida_max` no tick `ceil(corrida_max / corrida_aceleracao × 60)`, e nunca a ultrapassa. Com os valores de partida (`corrida_max` = 90 px/s, `corrida_aceleracao` = 1000 px/s²), isso é o tick 6 (0 → 16,7 → 33,3 → 50 → 66,7 → 83,3 → 90). O teste verifica a velocidade após o tick 5 (< `corrida_max`, 83,3 px/s) e após o tick 6 (= `corrida_max`, 90 px/s), não só o total de ticks.
- **CS-002** Partindo de `corrida_max` no chão e com entrada 0 a partir do tick 1, o Zé para no tick `ceil(corrida_max / corrida_aceleracao × 60)` (tick 6 com os valores de partida, freando com a mesma taxa `corrida_aceleracao`, conforme RF-002), sem que a velocidade troque de sinal. O teste verifica os mesmos ticks intermediários de CS-001 (tick 5 > 0, tick 6 = 0), na frenagem.
- **CS-003** Em queda livre, a velocidade vertical nunca passa de `queda_max`.
- **CS-004** Todos os RF têm teste GUT com o identificador no nome.
