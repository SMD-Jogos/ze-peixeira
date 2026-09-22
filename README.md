# Zé Peixeira

Prova de conceito de um controlador de personagem 2D no Godot 4, inspirado em *Celeste* e ambientado no sertão cearense. Foi desenvolvida com um fluxo **guiado por especificação** (SDD), em que um agente de IA escreve o código e um humano especifica, revisa e decide.

Material complementar de **Programação para Jogos I** (SMD/UFC). Não é um jogo completo, nem um roteiro obrigatório da disciplina.

## Por onde começar

1. **[docs/fluxo-sdd.md](docs/fluxo-sdd.md)**: o fluxo, o tutorial passo a passo e a estrutura deste repositório.
2. **[.specify/memory/constitution.md](.specify/memory/constitution.md)**: as regras que valem para todo o código.
3. **[specs/](specs/)**: uma pasta por fatia, cada uma com a especificação (escrita pelo humano) e, depois de executada, o plano e as tarefas (gerados pelo agente e revisados).
4. **[docs/review/](docs/review/)**: o que o agente errou em cada tarefa e como o erro foi percebido.

O mesmo conteúdo, em formato de apostila: **[docs/apostila-sdd-ze-peixeira.docx](docs/apostila-sdd-ze-peixeira.docx)**, gerada por `tools/apostila/` a partir dos arquivos Markdown. Os arquivos Markdown são a fonte: a apostila é regenerada depois de cada mudança.

**Para refazer o fluxo com outro agente**, parta da tag `specs-v1` (`git checkout specs-v1`): só constituição e specs, antes de qualquer código.

## Sobre a ferramenta de IA

O fluxo foi **executado com o Claude Code** e pensado para ser independente do agente: todos os artefatos são arquivos Markdown, e o [Spec Kit](https://github.com/github/spec-kit) oferece integração com outros agentes, como Gemini CLI e GitHub Copilot. **A execução com outros agentes não foi verificada.** A seção 8 de `docs/fluxo-sdd.md` propõe essa verificação como exercício.

## Versões usadas

| Ferramenta | Versão |
|---|---|
| Godot | 4.7.2.stable.official |
| Spec Kit (`specify`) | 1.0.10 |
| GUT | 9.7.1 |
| Agente e modelo | Claude Code, modelo Claude Sonnet 5 |

## Fatias

| Fatia | Mecânica | Status |
|---|---|---|
| 001-movimento | Corrida e gravidade | spec escrita |
| 002-pulo | Altura variável, coyote time, jump buffer | spec escrita |
| 003-maquina-de-estados | Refatoração para o padrão State | spec escrita |
| 004-dash-gibao | Dash; o gibão protege dos espinhos | spec escrita |
| 005-peixeira-arremesso | Peixeira cravada vira apoio | spec escrita |
| 006-corte-mandacaru | Corte abre caminho; fase de demonstração | spec escrita |

## Rodar os testes

```bash
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```
