# Fatia 001 — Movimento horizontal e gravidade

**Status:** especificação escrita pelo humano · **Depende de:** nenhuma

## Objetivo

O Zé corre para os lados com aceleração e desaceleração perceptíveis, cai com gravidade e é contido pelo terreno. É a base sobre a qual as outras fatias se apoiam.

## Cenários de aceitação

1. **Dado** o Zé parado no chão, **quando** o jogador segura `mover_direita`, **então** ele acelera até a velocidade máxima de corrida e a mantém enquanto a ação estiver pressionada.
2. **Dado** o Zé correndo, **quando** o jogador solta a direção, **então** ele desacelera até parar, sem inverter o sentido.
3. **Dado** o Zé correndo para a direita, **quando** o jogador passa a segurar `mover_esquerda`, **então** ele desacelera, inverte e acelera para a esquerda, e passa a olhar para a esquerda.
4. **Dado** o Zé no ar, **quando** o jogador segura uma direção, **então** ele acelera mais devagar do que no chão.
5. **Dado** o Zé sem chão embaixo, **então** ele cai com aceleração constante até uma velocidade máxima de queda.
6. **Dado** o Zé correndo em direção a uma parede, **quando** encosta nela, **então** para na horizontal e não a atravessa.
7. **Dado** o Zé na fase, **quando** cai abaixo do limite inferior da fase, **então** volta ao ponto inicial, parado.

## Casos-limite

- `mover_esquerda` e `mover_direita` pressionadas juntas: a entrada horizontal é 0.
- Velocidade horizontal acima da máxima no mesmo sentido da entrada (possível em fatias futuras, como o dash): reduz com a taxa `corrida_reducao`, mais suave, e não é cortada de uma vez.

## Requisitos funcionais

- **RF-001** A entrada horizontal é discreta: −1, 0 ou 1 (direita menos esquerda). Entrada analógica é arredondada para esses valores.
- **RF-002** A cada tick, a velocidade horizontal se aproxima do alvo `entrada × corrida_max`:
  - com taxa `corrida_reducao` quando |v| > `corrida_max` e o sentido de v é o mesmo da entrada;
  - com taxa `corrida_aceleracao` em todos os outros casos, inclusive com entrada 0 (frear usa a mesma taxa de acelerar).
  - A aproximação nunca ultrapassa o alvo.
- **RF-003** No ar, as taxas do RF-002 são multiplicadas por `multiplicador_ar`.
- **RF-004** A gravidade soma `gravidade × delta` à velocidade vertical a cada tick, até o limite `queda_max`.
- **RF-005** A direção do olhar é o sinal da última entrada horizontal diferente de 0. No início, o Zé olha para a direita.
- **RF-006** Ao cair abaixo de `limite_inferior_fase` (em pixels, no eixo y; propriedade da cena da fase, não do `PlayerTuning`), o Zé volta ao ponto inicial com velocidade zero.
- **RF-007** Existe uma fase de teste com chão plano, duas plataformas em alturas diferentes, uma parede e um vão por onde se pode cair.

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

## Fora do escopo

Pulo, dash, máquina de estados, espinhos, peixeira, câmera com suavização (a câmera é fixa na fase), animações, som.

## Critérios de sucesso

- **CS-001** Partindo do repouso no chão, com entrada constante, o Zé atinge `corrida_max` em `ceil(corrida_max / corrida_aceleracao × 60)` ticks, e nunca a ultrapassa.
- **CS-002** Partindo de `corrida_max` no chão e com entrada 0, o Zé para em `ceil(corrida_max / corrida_aceleracao × 60)` ticks, sem que a velocidade troque de sinal.
- **CS-003** Em queda livre, a velocidade vertical nunca passa de `queda_max`.
- **CS-004** Todos os RF têm teste GUT com o identificador no nome.
