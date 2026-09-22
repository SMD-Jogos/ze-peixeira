# Revisão 001-clarify — encerramento precoce do `/speckit.clarify`

**Fatia:** 001-movimento · **Tarefa:** `/speckit.clarify` · **Agente e modelo:** Claude Code, Sonnet 5 · **Data:** 2026-09-22

## O que foi pedido

Instrução original: rodar `/speckit.clarify` sobre `specs/001-movimento/spec.md`, mostrando as perguntas uma a uma, sem o agente responder por conta do humano.

## O que veio

Depois de 1 pergunta respondida (direção do olhar após o respawn), o agente fez uma segunda varredura da taxonomia de ambiguidade e concluiu, por conta própria:

> "Resultado honesto: não encontrei uma segunda ambiguidade no mesmo nível da primeira."

Listou cinco pontos considerados e descartados (colisão com parede, `limite_inferior_fase`/"ponto inicial", ramo `corrida_reducao`, flip visual do placeholder, ordem de operações em `ceil(...)`) e ofereceu ao humano, via pergunta de múltipla escolha, apenas duas opções: encerrar o clarify (recomendada) ou apontar uma área específica. O humano escolheu "Encerrar o clarify aqui (Recomendado)". O agente então registrou em `.specify/ultima-parada.md`:

> "`/speckit.clarify` sobre `specs/001-movimento/spec.md`, encerrado por decisão do humano após 1 pergunta (de até 5 possíveis) — não por esgotamento da cota."

## Problema

Tipo:

- [ ] API inexistente ou do Godot 3
- [ ] Violação da constituição (qual item: ___)
- [ ] Critério de aceitação não atendido (qual: ___)
- [ ] Escopo além da tarefa ou da spec
- [ ] Teste que não testa o critério
- [ ] Ambiguidade da spec (o agente não errou; a spec permitia essa leitura)
- [x] Outro: encerramento precoce por varredura incompleta do agente, com atribuição incorreta da decisão ao humano

Descrição: a varredura do agente foi rasa — não encontrou (entre outras) a falta de zona morta no RF-001, a ordem tick-a-tick de CS-001/CS-002, o estado inicial do personagem (chão ou queda) e a compatibilidade entre "câmera fixa" e o tamanho da fase do RF-007. Ao oferecer só "encerrar" como opção recomendada e o humano aceitar essa recomendação, o agente registrou o resultado como "decisão do humano" — mas quem decidiu que não havia mais ambiguidade foi o agente; o humano apenas aceitou uma avaliação que se mostrou incompleta.

## Como foi percebido

- [ ] Teste falhou
- [ ] Jogando
- [ ] Lendo o diff
- [ ] Console do Godot
- [x] Outro: revisão feita por uma segunda sessão de IA (Claude, no Cowork) atuando como revisora, repassada pelo humano — checklist de 6 itens específicos apontando lacunas que a varredura do agente não tinha visto

## O que mudou

- [ ] Só o código (pedido de correção ao agente)
- [ ] A tarefa (`tasks.md`)
- [x] A spec (`spec.md`), por decisão humana
- [ ] A constituição

Pedido de correção enviado, copiado literalmente:

> O `.specify/ultima-parada.md` diz que o clarify foi "encerrado por decisão do humano após 1 pergunta". Eu não encerrei [ajuste esta frase se tiver encerrado]. Corrija o registro e continue o `/speckit.clarify` da spec 001 até esgotar as perguntas (máx. 5 no total), uma por vez, sem responder por mim.

Seguido de uma checklist de 6 itens (limiar de arredondamento do RF-001; RF-005 entrada vs. velocidade; onde/como se definem "ponto inicial" e `limite_inferior_fase` no RF-006; RF-007 caber em 320×180; contagem de tick em CS-001/CS-002; estado inicial no chão ou em queda), pedindo para o agente dizer, sem resolver, se cada item tinha sido tratado por alguma pergunta do clarify.

Resultado: `.specify/ultima-parada.md` corrigido para descrever a atribuição errada; `/speckit.clarify` retomado até esgotar as 5 perguntas (4 novas: estado inicial, contagem de tick, zona morta do RF-001, tamanho da fase do RF-007). Da checklist de 6 itens, **4 foram tratados** pelas perguntas retomadas do clarify (RF-001, RF-007, CS-001/CS-002, estado inicial); **2 exigiram decisão humana direta**, fora do fluxo de perguntas do clarify (RF-005, confirmado pelo humano como já resolvido no texto original; RF-006, onde a definição de "ponto inicial" e `limite_inferior_fase` foi decidida pelo humano como responsabilidade da cena, deixando o "como" para o `/speckit.plan`).

## Lição

Antes de declarar "não há mais ambiguidades" e encerrar uma etapa de verificação, usar uma lista de checagem explícita (por categoria de requisito, não só uma impressão geral) — e nunca atribuir ao humano uma decisão que foi, de fato, uma avaliação do próprio agente apenas aceita por ele.
