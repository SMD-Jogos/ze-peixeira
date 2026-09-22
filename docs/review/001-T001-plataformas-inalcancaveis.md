# Revisão 001-T001 — plataformas inalcançáveis e 0,5 px de folga no ponto inicial

**Fatia:** 001-movimento · **Tarefa:** T001 · **Agente e modelo:** Claude Code, Sonnet 5 · **Data:** 2026-09-22

## O que foi pedido

Trecho de `tasks.md`: "T001 Criar `game/scenes/fase_teste.tscn`: chão plano, duas plataformas em alturas diferentes, uma parede, um vão (RF-007); um nó `Marker2D` chamado `PontoInicial`; uma `Camera2D` fixa enquadrando a fase inteira em 320×180 [...]. **Fim**: `F5` abre a fase e o Zé aparece parado, azul, sobre o chão."

## O que veio

O agente construiu a cena com `PontoInicial` em `Vector2(20, 154)`, sobre o segmento de chão `ChaoEsquerda` (superfície em y=160), com as duas plataformas (`PlataformaA` em y=120, `PlataformaB` em y=90) e a parede posicionadas no ar, alcançáveis só por pulo.

## Problema

Tipo:

- [ ] API inexistente ou do Godot 3
- [ ] Violação da constituição (qual item: ___)
- [ ] Critério de aceitação não atendido (qual: ___)
- [ ] Escopo além da tarefa ou da spec
- [ ] Teste que não testa o critério
- [x] Ambiguidade da spec (o agente não errou; a spec permitia essa leitura)
- [x] Outro: erro de posicionamento (0,5 px) no `PontoInicial`, sem relação com a ambiguidade acima

Descrição:

1. **Ambiguidade da spec, não erro do agente**: `RF-007` (fase de teste) e `RF-008` (estado inicial) não diziam onde, na fase, o ponto inicial deveria ficar. O agente colocou o Zé no chão, leitura razoável do texto original — mas a fatia 001 não tem pulo (fora do escopo, fatia 002), então nenhuma plataforma listada em `RF-007` é alcançável a partir do chão, e os Cenários 4 ("no ar, segurando uma direção") e 5 ("sem chão embaixo, cai") ficam impossíveis de testar jogando, só via teste GUT isolado da regra pura. Isso só ficou visível depois que a cena foi de fato construída (T001) — não era óbvio na leitura da spec sozinha.
2. `PontoInicial` em `Vector2(20, 154)`: a colisão do Zé (8×11, centrada na origem do `CharacterBody2D`) tem sua base em `154 + 5.5 = 159.5`, 0,5 px acima da superfície do chão (y=160) — não "apoiado", tecnicamente flutuando 0,5 px.

## Como foi percebido

- [ ] Teste falhou
- [ ] Jogando
- [ ] Lendo o diff
- [ ] Console do Godot
- [x] Outro: revisão da cena feita por uma segunda sessão de IA (Claude, atuando como revisora), repassada pelo humano — mesmo padrão já usado noutras revisões desta sessão (ver `docs/review/001-clarify-encerramento-precoce.md`)

## O que mudou

- [x] Só o código (pedido de correção ao agente)
- [ ] A tarefa (`tasks.md`)
- [x] A spec (`spec.md`), por decisão humana
- [ ] A constituição

Pedido de correção enviado, copiado literalmente:

> 1. PontoInicial em y=154 deixa os pés do Zé em 159,5, 0,5 px acima do chão (160). RF-008 exige começar apoiado. Posicione o PontoInicial para que a base da colisão do Zé coincida exatamente com a superfície onde ele nasce.
> 2. Lacuna da spec revelada pela implementação: sem pulo, nenhuma plataforma é alcançável, e os Cenários 4 e 5 não são testáveis jogando. Decisão minha: spec.md, RF-007: acrescente "o ponto inicial fica sobre uma plataforma elevada, de onde o Zé sai andando e cai — o que torna os Cenários 4 e 5 testáveis sem pulo (fatia 002)"; e no RF-008 deixe claro que "apoiado no chão" inclui estar sobre uma plataforma. [...] fase_teste.tscn: mova o PontoInicial (e a instância do Jogador) para cima da PlataformaA, com a base da colisão exatamente na superfície dela (y=120).

Resultado: `PontoInicial` e a instância de `Jogador` movidos para `Vector2(60, 114.5)` — base da colisão (`114.5 + 5.5 = 120`) exatamente na superfície de `PlataformaA` (topo em y=120). `spec.md` atualizado (RF-007, RF-008, Clarifications) para registrar a decisão.

## Lição

Construir a cena de teste é, em si, uma forma de verificação da spec: uma fase inalcançável sem uma mecânica ainda fora do escopo só aparece como problema depois que alguém tenta percorrê-la de verdade — vale revisar a cena logo após a primeira tarefa de Setup, antes de escrever qualquer regra, exatamente como aconteceu aqui.
