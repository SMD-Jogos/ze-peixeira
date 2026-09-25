# Fatia 004 — Dash e gibão de couro

**Status:** especificação escrita pelo humano · **Depende de:** 003-maquina-de-estados

## Objetivo

O Zé dá um arranque curto e rápido em qualquer uma das 8 direções. Os espinhos da fase matam ao contato, mas durante o dash o **gibão de couro** protege: o Zé atravessa os espinhos enquanto o dash durar.

## Clarifications

### Decisão do humano (revisão) 2026-09-25

- D: RF-007 — ao reaparecer, o Zé também volta a olhar para a direita (mesmo estado inicial da fatia 001, RF-005/RF-008).

## Cenários de aceitação

1. **Dado** o Zé com o dash disponível, **quando** o jogador aperta `dash` segurando uma direção, **então** ele se desloca rápido nessa direção por um instante, sem sofrer gravidade.
2. **Dado** o Zé sem direção pressionada, **quando** aperta `dash`, **então** o dash sai na horizontal, para o lado em que ele olha.
3. **Dado** o Zé que já usou o dash no ar, **quando** aperta `dash` de novo antes de tocar o chão, **então** nada acontece.
4. **Dado** o Zé que usou o dash, **quando** toca o chão, **então** o dash volta a estar disponível.
5. **Dado** o Zé fora do dash, **quando** encosta em espinhos, **então** morre e reaparece no ponto de reaparecimento.
6. **Dado** o Zé em dash, **quando** atravessa espinhos, **então** não morre.
7. **Dado** o Zé cujo dash termina ainda sobre espinhos, **então** ele morre no tick em que o dash termina.

## Requisitos funcionais

- **RF-001** `Dash` é um novo estado da máquina da fatia 003. Acrescentá-lo altera só as transições dos estados existentes, não o comportamento interno deles.
- **RF-002** A direção do dash é a entrada em 8 direções (`mover_*`), normalizada. Sem entrada, é a direção do olhar na horizontal.
- **RF-003** Durante `dash_duracao`, a velocidade é `direção × dash_velocidade`. Gravidade e entrada horizontal são ignoradas.
- **RF-004** Ao terminar o dash, se a magnitude da velocidade for maior que `dash_velocidade_final`, ela é reduzida a esse valor, mantendo a direção. Depois disso valem as regras normais (001 e 002).
- **RF-005** Há uma carga de dash. Ela é gasta ao iniciar o dash e restaurada quando o Zé está no chão **fora** do estado `Dash`.
- **RF-006** Entre o início de um dash e o próximo há um intervalo mínimo de `dash_recarga` segundos, mesmo com carga disponível.
- **RF-007** Espinhos são `Area2D`. O contato fora do estado `Dash` leva ao estado `Morto`: o Zé fica invisível e parado por `tempo_reaparecer` e volta no último ponto de reaparecimento, com velocidade zero, carga de dash restaurada e olhando para a direita (mesmo estado inicial da fatia 001, RF-005/RF-008). Cair abaixo do limite da fase (001, RF-006) passa a levar também ao estado `Morto`.
- **RF-008** Ao morrer, o jogador emite o sinal `morreu`, e ao reaparecer, `reapareceu` (Observer). Outros objetos reagem a esses sinais, sem que o jogador os conheça.
- **RF-009** Durante o estado `Dash`, o visual do Zé muda para a cor do gibão (marrom), indicando que a proteção está ativa.

## Afinação (valores de partida)

| Campo | Valor |
|---|---|
| `dash_velocidade` | 240 px/s |
| `dash_duracao` | 0,15 s |
| `dash_velocidade_final` | 160 px/s |
| `dash_recarga` | 0,2 s |
| `tempo_reaparecer` | 0,5 s |

## Fora do escopo

Quicar na parede com o dash, combinações de dash com pulo (como *super dash*), partículas, tremor de tela, animação de morte, mais de uma carga de dash.

## Critérios de sucesso

- **CS-001** A distância percorrida num dash horizontal no chão, sem obstáculos, é `dash_velocidade × dash_duracao` (±1 tick de deslocamento).
- **CS-002** Dois apertos de `dash` no mesmo pulo resultam em um único dash.
- **CS-003** Atravessar uma faixa de espinhos mais estreita que a distância do dash, começando o dash antes dela, não mata; parar sobre ela, mata.
- **CS-004** Os testes das fatias 001 a 003 continuam passando.
- **CS-005** A tabela de transições do plano inclui `Dash` e `Morto`, e existe teste para cada transição nova.
