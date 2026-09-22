# Fatia 002 — Pulo

**Status:** especificação escrita pelo humano · **Depende de:** 001-movimento

## Objetivo

O pulo responde à intenção do jogador, não só ao quadro exato em que o botão foi apertado. Toque curto dá pulo baixo, botão segurado dá pulo alto. Apertar um pouco antes de tocar o chão ou um pouco depois de sair da borda ainda conta.

## Cenários de aceitação

1. **Dado** o Zé no chão, **quando** o jogador aperta `pular`, **então** ele sobe.
2. **Dado** o Zé subindo após um pulo, **quando** o jogador solta `pular` cedo, **então** o pulo é mais baixo do que se tivesse segurado.
3. **Dado** o Zé que saiu de uma plataforma andando, sem pular, **quando** o jogador aperta `pular` logo depois, **então** o pulo acontece normalmente (*coyote time*).
4. **Dado** o Zé caindo perto do chão, **quando** o jogador aperta `pular` pouco antes de tocar o chão, **então** ele pula no tick em que toca o chão (*jump buffer*).
5. **Dado** o Zé no ar depois de ter pulado, **quando** o jogador aperta `pular` de novo, **então** nada acontece (não há pulo duplo), a menos que o cenário 4 se aplique.
6. **Dado** o Zé subindo, **quando** bate a cabeça no teto, **então** para de subir e começa a cair.

## Casos-limite

- Segurar `pular` ao aterrissar **não** dispara novo pulo. Só um aperto dentro da janela de buffer dispara.
- O coyote time só existe quando o Zé sai do chão **sem ter pulado**. Depois de um pulo, ele não é concedido.
- Um aperto de `pular` é consumido por um único pulo: não pode disparar o pulo pelo buffer e, de novo, pelo coyote time.

## Requisitos funcionais

- **RF-001** Pular define a velocidade vertical como `pulo_velocidade` (negativa, para cima no Godot) e consome a possibilidade de pular até o próximo contato com o chão.
- **RF-002** **Altura variável.** Por até `pulo_tempo_variavel` segundos após o pulo, enquanto `pular` estiver segurado, a velocidade vertical não fica mais lenta que `pulo_velocidade` (a gravidade não freia a subida). Soltar `pular` encerra esse período de vez.
- **RF-003** **Meia gravidade no ápice.** Enquanto `pular` estiver segurado e |velocidade vertical| < `apice_limiar`, a gravidade é multiplicada por 0,5.
- **RF-004** **Coyote time.** Ao sair do chão sem ter pulado, o pulo continua disponível por `janela_coyote` segundos.
- **RF-005** **Jump buffer.** Um aperto de `pular` feito no ar fica guardado por `janela_buffer` segundos. Se o Zé tocar o chão nesse intervalo, pula no tick do contato.
- **RF-006** Ao bater no teto, a velocidade vertical é zerada e o período do RF-002 termina.
- **RF-007** **Conversão de janelas em ticks:** `ticks = round(segundos × 60)`. Com os valores de partida, `janela_coyote` = 6 ticks e `janela_buffer` = 5 ticks.
- **RF-008** As regras de coyote, buffer e altura variável ficam numa classe pura (constituição, 2.1) que recebe, a cada tick, se o Zé está no chão, se `pular` foi apertado neste tick e se está segurado, e devolve se deve pular.

## Afinação (valores de partida)

| Campo | Valor |
|---|---|
| `pulo_velocidade` | −105 px/s |
| `pulo_tempo_variavel` | 0,2 s |
| `apice_limiar` | 40 px/s |
| `janela_coyote` | 0,1 s |
| `janela_buffer` | 0,08 s |

## Fora do escopo

Pulo na parede, pulo duplo, impulso horizontal no pulo, correção de quina, dash, máquina de estados (vem na 003).

## Critérios de sucesso

- **CS-001** Coyote: apertar `pular` no tick 1 a 6 depois de sair da borda executa o pulo; no tick 7, não.
- **CS-002** Buffer: um aperto 1 a 5 ticks antes do contato com o chão pula no tick do contato; um aperto 6 ticks antes, não.
- **CS-003** A altura máxima com `pular` segurado é maior do que com `pular` solto no primeiro tick.
- **CS-004** Os testes da fatia 001 continuam passando sem alteração.
- **CS-005** Todos os RF têm teste GUT com o identificador no nome.
