# Fatia 005 — Arremesso da peixeira

**Status:** especificação escrita pelo humano · **Depende de:** 004-dash-gibao

## Objetivo

A peixeira é ferramenta, não arma. Arremessada contra uma parede, ela fica cravada e vira um pequeno apoio onde o Zé pode subir. Só existe uma peixeira: enquanto ela está fora da mão, não há outra.

## Cenários de aceitação

1. **Dado** o Zé com a peixeira na mão, **quando** o jogador aperta `arremessar`, **então** a peixeira voa na horizontal, para o lado em que o Zé olha.
2. **Dado** a peixeira voando, **quando** atinge uma parede do terreno, **então** fica cravada no ponto de contato.
3. **Dado** a peixeira cravada, **quando** o Zé cai sobre ela vindo de cima, **então** ele fica de pé sobre ela, como numa plataforma.
4. **Dado** a peixeira cravada, **quando** o Zé passa por ela vindo de baixo ou de lado, **então** a atravessa sem colidir.
5. **Dado** a peixeira voando, **quando** percorre o alcance máximo sem atingir nada, **então** volta para a mão.
6. **Dado** a peixeira voando ou cravada, **quando** o jogador aperta `arremessar` de novo, **então** ela volta para a mão na hora. Se o Zé estava de pé sobre ela, cai.
7. **Dado** o Zé em dash, **quando** o jogador aperta `arremessar`, **então** nada acontece.

## Casos-limite

- A peixeira atinge espinhos: volta para a mão, sem cravar. (O mandacaru só existe a partir da fatia 006, que define o mesmo comportamento para ele.)
- O Zé morre com a peixeira fora da mão: ela volta para a mão ao reaparecer.
- O Zé arremessa encostado numa parede: a peixeira crava imediatamente, no ponto mais próximo à frente dele.

## Requisitos funcionais

- **RF-001** A peixeira tem sua própria máquina de estados, **concorrente** à do movimento do Zé (seção *Concurrent State Machines* do capítulo "State"): `NaMao`, `Voando`, `Cravada`. O estado da peixeira não é um estado do movimento.
- **RF-002** Em `Voando`, ela se move em linha reta a `peixeira_velocidade`, sem gravidade, até atingir terreno ou percorrer `peixeira_alcance`.
- **RF-003** Em `Cravada`, ela é uma plataforma de mão única, com largura `peixeira_largura_apoio`, colidindo só por cima.
- **RF-004** O arremesso é possível no chão e no ar, fora do estado `Dash`.
- **RF-005** A peixeira emite os sinais `cravou` e `recolhida`. O jogador não verifica o estado dela a cada tick: reage aos sinais ou consulta o estado apenas quando o jogador aperta `arremessar`.
- **RF-006** Ao receber `reapareceu` (fatia 004), a peixeira volta para `NaMao`.
- **RF-007** Visual: retângulo fino cinza-claro (constituição, 3.2). Na mão, não é desenhada.

## Afinação (valores de partida)

| Campo | Valor |
|---|---|
| `peixeira_velocidade` | 300 px/s |
| `peixeira_alcance` | 96 px |
| `peixeira_largura_apoio` | 8 px |

## Fora do escopo

Arremesso na diagonal ou para cima, mira, ricochete, cravar no chão ou no teto, dano a qualquer coisa, animação de giro.

## Critérios de sucesso

- **CS-001** Nunca há mais de uma peixeira na cena.
- **CS-002** A fase de teste tem uma parede mais alta que o pulo máximo do Zé (calculado a partir da afinação da fatia 002 e registrado no plano). Ela só pode ser escalada assim: arremessar a peixeira perto do ápice de um pulo, subir nela e pular dela até o topo.
- **CS-003** Os testes das fatias 001 a 004 continuam passando.
- **CS-004** Existe teste para cada transição da máquina da peixeira.
