# Revisão 000-P3 — o tutorial descreve um mecanismo de fatia ativa que não existe na versão instalada

**Fatia:** 000-ambiente · **Tarefa:** P3 (investigação da fatia ativa antes de abrir a fatia 001) · **Agente e modelo:** Claude Code, Sonnet 5 · **Data:** 2026-09-22

## O que foi pedido

Trecho da instrução do humano:

> Leia os scripts em `.specify/scripts/` e os comandos/skills em `.claude/` e me explique, citando arquivo e trecho, como `/speckit.clarify`, `/speckit.plan` e `/speckit.tasks` descobrem a fatia ativa (variável `SPECIFY_FEATURE`, `.specify/feature.json`, branch git ou outro). Diga o que eu preciso fazer para que usem `specs/001-movimento/spec.md`, que já existe, sem criar uma pasta nova.

## O que veio

O agente leu `.specify/scripts/bash/common.sh` e os três `SKILL.md` citados e relatou que:

- `get_current_branch()` (`common.sh:79-88`) só lê `SPECIFY_FEATURE` para compor o rótulo `BRANCH` exibido; essa variável **não** seleciona o diretório da fatia.
- `get_feature_paths()` (`common.sh:163-231`) resolve o `FEATURE_DIR` de verdade nesta ordem: (1) variável de ambiente `SPECIFY_FEATURE_DIRECTORY`, persistida em `.specify/feature.json` se usada; (2) a chave `"feature_directory"` de `.specify/feature.json`; (3) erro.
- Nenhum `SKILL.md` em `.claude/skills/` referencia `SPECIFY_FEATURE` (`grep -rn "SPECIFY_FEATURE\b" .claude/skills/` não retornou nada); `/speckit.clarify` (`speckit-clarify/SKILL.md:66`) chama `check-prerequisites.sh --json --paths-only`, e `/speckit.plan` e `/speckit.tasks` chamam `setup-plan.sh`/`setup-tasks.sh` — ambos chamam `get_feature_paths()` diretamente (`setup-plan.sh:31`, `setup-tasks.sh:26`).
- Não há nenhuma referência a `git branch`/`git rev-parse`/`checkout -b` em `.specify/scripts/`.

Conclusão correta: a instrução `export SPECIFY_FEATURE=001-movimento`, escrita em `docs/fluxo-sdd.md` (Passo 3, e repetida no Passo 9 para `002-pulo`), **não tem efeito** sobre qual `spec.md` os comandos usam na versão instalada (Spec Kit v1.0.10). O próprio `docs/fluxo-sdd.md` já avisava, na seção 5, que "as opções de linha de comando do Spec Kit mudaram entre versões: o que está escrito abaixo corresponde à documentação da versão 1.x" — o texto ficou desatualizado em relação à v1.0.10 realmente instalada.

**Este erro é do documento `docs/fluxo-sdd.md`, escrito pelo humano antes da execução — não é um erro de código ou de decisão do agente durante a fatia.** O agente não alterou o documento sem autorização; reportou o problema e aguardou a decisão do humano, que pediu a correção no Passo C.1 desta mesma rodada.

## Problema

Tipo:

- [ ] API inexistente ou do Godot 3
- [ ] Violação da constituição (qual item: ___)
- [ ] Critério de aceitação não atendido (qual: ___)
- [ ] Escopo além da tarefa ou da spec
- [ ] Teste que não testa o critério
- [ ] Ambiguidade da spec (o agente não errou; a spec permitia essa leitura)
- [x] Outro: erro de documentação (`docs/fluxo-sdd.md`, Passos 3 e 9), escrito pelo humano com base numa versão anterior do Spec Kit — não é erro do agente

## Como foi percebido

- [ ] Teste falhou
- [ ] Jogando
- [ ] Lendo o diff
- [ ] Console do Godot
- [x] Outro: leitura do código-fonte de `.specify/scripts/bash/common.sh` e dos `SKILL.md` de `.claude/skills/`, a pedido do humano, antes de rodar qualquer `/speckit.*`

## O que mudou

- [ ] Só o código (pedido de correção ao agente)
- [ ] A tarefa (`tasks.md`)
- [ ] A spec (`spec.md`), por decisão humana
- [ ] A constituição
- [x] Outro: `docs/fluxo-sdd.md` (Passos 1, 3 e 9) — tutorial escrito pelo humano, corrigido no mesmo commit deste registro

Pedido de correção enviado, copiado literalmente:

> C.1. `docs/fluxo-sdd.md`, Passos 3 e 9: troque `export SPECIFY_FEATURE=...` por `echo '{"feature_directory":"specs/001-movimento"}' > .specify/feature.json` (e `002-pulo` no Passo 9), com uma frase explicando que a fatia ativa é lida de `.specify/feature.json` (ou da variável `SPECIFY_FEATURE_DIRECTORY`) desde a v1.0.x.

## Lição

O texto do tutorial refletia uma versão anterior do Spec Kit (a própria seção 5 do documento já alertava para isso); depois de instalar a ferramenta de verdade, os trechos de comando do tutorial precisam ser revalidados contra o código-fonte efetivamente instalado (`.specify/scripts/`), não contra a lembrança de como uma versão anterior se comportava.
