# Checklist de revisão de tarefa

Usado depois de **cada** tarefa implementada pelo agente, antes do commit. Um item marcado "não" bloqueia o aceite.

## Rodou?

- [ ] Os testes GUT passam (todas as fatias, não só a atual).
- [ ] O jogo abre e a mecânica da tarefa funciona com o controle na mão.
- [ ] O console do Godot não mostra erros nem avisos novos.

## Fez o que foi pedido, e só isso?

- [ ] O diff corresponde a **uma** tarefa de `tasks.md`.
- [ ] Os critérios de aceitação ligados à tarefa foram verificados, um a um.
- [ ] Nada de *Fora do escopo* foi implementado.
- [ ] `spec.md` e a constituição não foram alterados.

## Respeitou a constituição?

- [ ] Nenhuma API do Godot 3 (tabela 1.2).
- [ ] As regras de decisão estão em `scripts/regras/`, sem acesso a nós, física ou `Input`.
- [ ] Não há números literais de movimento no código: tudo vem de `PlayerTuning`.
- [ ] A entrada é lida só pelas ações nomeadas.
- [ ] Objetos do mundo se comunicam por sinais ou `Area2D`, não por chamadas diretas ao jogador.
- [ ] Colisão e visual continuam separados.

## Consigo explicar?

- [ ] Sei dizer o que cada função nova faz e por que está naquele arquivo.
- [ ] Sei qual padrão de projeto foi usado e por que ele cabe aqui.
- [ ] Os testes novos testam o critério de aceitação, e não só "que o código roda".

Se algum item falhou: registrar em `docs/review/` (modelo em `_modelo.md`) antes de pedir a correção ao agente.
