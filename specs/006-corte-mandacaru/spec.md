# Fatia 006 — Corte com a peixeira e mandacaru

**Status:** especificação escrita pelo humano · **Depende de:** 005-peixeira-arremesso

## Objetivo

Com a peixeira na mão, o Zé corta o mandacaru que fecha a passagem. O corte não interrompe o movimento: dá para correr e pular cortando. Esta fatia fecha a fase de demonstração, que passa a exigir todas as mecânicas.

## Cenários de aceitação

1. **Dado** o Zé com a peixeira na mão, **quando** o jogador aperta `cortar`, **então** uma área de corte aparece por um instante à frente dele.
2. **Dado** um mandacaru dentro da área de corte, **então** ele é removido e a passagem se abre.
3. **Dado** o Zé com a peixeira fora da mão (voando ou cravada), **quando** o jogador aperta `cortar`, **então** nada acontece.
4. **Dado** o Zé correndo ou no ar, **quando** corta, **então** continua se movendo normalmente.
5. **Dado** um mandacaru já cortado, **quando** o Zé morre e reaparece, **então** o mandacaru volta ao lugar.
6. **Dado** o Zé em dash, **quando** o jogador aperta `cortar`, **então** nada acontece.

## Requisitos funcionais

- **RF-001** O corte **não é um estado do movimento**. É um componente do Zé (nó filho com `Area2D`), ativado por `corte_duracao` segundos, na direção do olhar, com tamanho `corte_largura × corte_altura`. O plano justifica essa escolha em relação a criar um estado `Cortando`.
- **RF-002** Entre um corte e o próximo há um intervalo mínimo de `corte_recarga` segundos.
- **RF-003** O corte só acontece com a peixeira em `NaMao` (fatia 005) e fora do estado `Dash`.
- **RF-004** O mandacaru é um corpo sólido (bloqueia o Zé como o terreno). Atingido pelo corte, é desativado (sem colisão, invisível) e emite o sinal `cortado`.
- **RF-005** Ao receber `reapareceu` (fatia 004), todo mandacaru cortado volta a ficar ativo. O jogador não conhece os mandacarus: a reação vem do sinal.
- **RF-006** Visual: retângulo vertical verde (constituição, 3.2). A área de corte ativa é desenhada como contorno enquanto `depuracao_estados` estiver ligado.
- **RF-007** **Fase de demonstração**, em sequência: um vão (pulo), uma faixa de espinhos (dash), uma parede alta (peixeira como apoio) e um mandacaru fechando a saída (corte). Um ponto de reaparecimento antes de cada trecho.
- **RF-008** A peixeira arremessada que atinge um mandacaru volta para a mão, sem cravar e sem cortá-lo.

## Afinação (valores de partida)

| Campo | Valor |
|---|---|
| `corte_duracao` | 0,1 s |
| `corte_recarga` | 0,3 s |
| `corte_largura` | 12 px |
| `corte_altura` | 10 px |

## Fora do escopo

Inimigos, dano, combos, corte em outras direções, mandacaru que precisa de mais de um golpe, pontuação, efeitos visuais.

## Critérios de sucesso

- **CS-001** A fase de demonstração pode ser concluída, e só pode ser concluída usando as quatro mecânicas: pulo, dash, peixeira como apoio e corte.
- **CS-002** Cortar enquanto a peixeira está cravada não abre o mandacaru.
- **CS-003** Os testes das fatias 001 a 005 continuam passando.
- **CS-004** Existe teste para cada RF, exceto o RF-007, que é verificado em playtest e registrado em `docs/review/`.
