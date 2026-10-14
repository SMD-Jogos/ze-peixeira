# Review 2026-10-13 — Instalar o método de trabalho a três

**Autor:** revisor (Fable, sessão Cowork) · **Para:** Claude Code · **Modelo recomendado:** Sonnet

## Diagnóstico

- Não há `CLAUDE.md`. As regras estáveis estão em `.specify/memory/constitution.md` (o agente não a altera) e o processo em `docs/fluxo-sdd.md`. Isso fica como está: o `CLAUDE.md` novo aponta para eles, não os duplica.
- Não há `docs/STATUS.md`. O estado vive na tabela "Fatias" do `README.md` e em `.specify/ultima-parada.md`, que é checkpoint do agente e está no `.gitignore`. Estado mutável passa a ficar em `docs/STATUS.md`.
- `docs/review/` é o **registro didático dos erros do agente** (material da disciplina; modelo em `_modelo.md`). Não muda de uso. Os pareceres do revisor ficam em **`docs/revisao/`** (esta pasta).
- O item 5.1 da constituição ("uma tarefa por vez; o agente para ao terminar") já é o Modo de trabalho do método. Nada a mudar nas regras.
- O comando de teste (README) dá **falso verde** em dois casos, verificados em 13/10/2026 no Mac mini: erro de parse num arquivo de teste (Godot pula o arquivo, imprime "All tests passed!", exit 0) e diretório de testes inexistente ("Nothing was run", exit 0). Isso vai para "Armadilhas".

## O que fazer, em UM commit (`docs: instala o método de trabalho a três`)

### 1. Criar `CLAUDE.md` na raiz

```markdown
# Zé Peixeira — orientações para o Claude Code

Regras do código: `.specify/memory/constitution.md` (não alterar; propor mudanças ao George).
Processo SDD e estrutura: `docs/fluxo-sdd.md`. Estado atual: `docs/STATUS.md`.
Especificações: `specs/NNN-nome/` (spec.md pelo humano; plan.md e tasks.md gerados e revisados).

## Modo de trabalho

- **Passos pequenos, validados um a um.** Cada tarefa entrega uma unidade
  verificável (uma tarefa `TXXX` de `tasks.md`, com seu teste GUT passando)
  e para. Não encadeie a próxima tarefa sem o George validar a anterior.
- **Proponha antes de executar.** Para qualquer mudança que toque mais de um
  arquivo, ou altere `scripts/regras/`, `PlayerTuning`, `project.godot`,
  uma cena `.tscn` ou a assinatura de um sinal, apresente o plano (o quê,
  onde, por quê, como validar) e espere aprovação.
- **Um commit por unidade validada**, mensagem descritiva, sem push.
- **Mostre como validar.** Toda entrega termina com "como você confere isso":
  o comando de teste e, quando couber, o que ver jogando.
- **Na dúvida, pergunte** — perguntar custa uma mensagem; desfazer custa horas.
- **Estreitar escopo é divergência.** Se entregar menos (ou diferente) do que
  foi pedido, registre em `docs/STATUS.md` como divergência, com o motivo —
  nunca descreva o entregue como se fosse o pedido.
- `spec.md` e a constituição nunca são alterados pelo agente.

## Colaboração a três (George · Claude Code · Revisor)

- **George** decide. Aprova cada passo antes e valida o resultado depois.
  No modo lote (ver `docs/revisao/`), aprova o lote do dia e responde o que
  o revisor não consegue decidir.
- **Claude Code** implementa, testa, commita e mantém `docs/STATUS.md`.
  Não edita `docs/revisao/` nem `docs/review/`, mas commita o que estiver
  em `docs/revisao/` junto com o passo correspondente.
- **Revisor** (Fable numa sessão Cowork, ou Jurubeba no modo lote) revisa e
  planeja. Escreve SOMENTE em `docs/revisao/`.
- `docs/review/` é outra coisa: o registro didático dos erros do agente,
  escrito pelo George (modelo em `docs/review/_modelo.md`).

Fluxo de um passo:
1. O revisor deixa em `docs/revisao/AAAA-MM-DD-<assunto>.md` o parecer e o
   prompt do próximo passo. George diz "lê a review e segue".
2. Claude Code lê a review mais recente, propõe o plano, George aprova,
   Claude Code implementa e commita.
3. Ao final, Claude Code atualiza `docs/STATUS.md`: feito (commit), aguardando
   aprovação, dúvidas, divergências com a última review.
4. O revisor lê STATUS.md + diff, revisa, escreve a próxima review.

Se uma review contradiz o repositório, o REPOSITÓRIO prevalece e a divergência
vai para STATUS.md. Se o Claude Code discordar de uma review, diz por quê em
STATUS.md antes de implementar — nunca implementa a discordância em silêncio.

## Comandos

- Testes (da raiz): `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`
- Antes dos testes, após criar `class_name` novo: `godot --headless --path game --import`
- Aceite dos testes é **composto** (o exit code não basta): exit 0 **e**
  "All tests passed!" **e** nenhuma linha `SCRIPT ERROR` / `ERROR:` /
  `[GUT ERROR]` / `Parse Error` **e** `Scripts N` igual ao número de
  `game/tests/test_*.gd` **e** nunca menos testes que na última execução aprovada.

## Armadilhas conhecidas

- Erro de parse num arquivo de teste: o Godot pula o arquivo e imprime
  "All tests passed!" com exit 0. Falso verde. Por isso o aceite composto.
- Diretório de testes errado: "Nothing was run", exit 0. Falso verde.
- `.specify/ultima-parada.md` é checkpoint do agente, não estado do projeto;
  está no `.gitignore`. O estado é `docs/STATUS.md`.
- A apostila (`docs/apostila-sdd-ze-peixeira.docx`) é gerada dos Markdown;
  mudança em `docs/fluxo-sdd.md` pede regeneração (`tools/apostila/`), em
  passo separado.
```

### 2. Criar `docs/STATUS.md`

```markdown
# STATUS — Zé Peixeira

Mantido pelo Claude Code. Estado corrente; regras estáveis ficam na
constituição e em `CLAUDE.md`. Pareceres do revisor em `docs/revisao/`.

**Última atualização:** 2026-10-13

## Estado atual

- Fatia **001-movimento**: concluída (`5a1d72a`, playtest T009; `dba64f6`, T011).
  Material da aula em `722be92`.
- Fatias **002 a 006**: só `spec.md`. Sem `plan.md` nem `tasks.md`.
- Testes: 2 scripts, 18 testes, 41 asserts, passando (13/10/2026, Mac mini, Godot 4.7.2).

## Aguardando aprovação

- (vazio)

## Divergências com a última review

- (vazio)

## Pendências

- Plano e tarefas da fatia 002-pulo (`/speckit.plan`, `/speckit.tasks`), com o George.
- Regenerar a apostila após a mudança em `docs/fluxo-sdd.md` (passo separado).
```

### 3. Atualizar `docs/fluxo-sdd.md`, seção 10 "Estrutura do repositório"

Acrescentar três entradas, uma linha cada, no formato já usado na seção:
`CLAUDE.md` (orientações para o agente; aponta para constituição e fluxo), `docs/STATUS.md` (estado corrente, mantido pelo agente) e `docs/revisao/` (pareceres do revisor; diferente de `docs/review/`, que é o registro didático). Não remover nem reescrever nada.

### 4. Não fazer neste commit

- Não regenerar a apostila. Não tocar em `README.md`, `specs/`, constituição, `game/`.
- Não criar `plan.md`/`tasks.md` de nenhuma fatia.

## Critério de aceite

1. `git diff --stat` mostra só: `CLAUDE.md`, `docs/STATUS.md`, `docs/fluxo-sdd.md`, `docs/revisao/2026-10-13-metodo-de-trabalho.md`.
2. Em `docs/fluxo-sdd.md`, `git diff` tem só linhas adicionadas (nenhuma removida).
3. Comando de teste: exit 0, "All tests passed!", `Scripts 2`, 18 testes, nenhuma linha de erro.
4. Constituição e `specs/` byte-idênticos (`git diff --quiet -- .specify specs` retorna 0).

## Prompt para o Claude Code

`Lê docs/revisao/2026-10-13-metodo-de-trabalho.md e segue. Plano curto antes de mexer.`
