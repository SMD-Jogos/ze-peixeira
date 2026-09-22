# Desenvolvimento de jogos guiado por especificação (SDD) com agentes de IA

Material complementar de **Programação para Jogos I** (SMD/UFC). Demonstra um fluxo de desenvolvimento guiado por especificação (*Spec-Driven Development*, SDD) em que um agente de IA escreve o código e um humano especifica, revisa e decide. O caso de estudo é o **Zé Peixeira**: uma prova de conceito de controlador de personagem 2D inspirado em *Celeste*, ambientado no sertão cearense.

## 1. Sobre este material

**O que é.** Uma demonstração do processo, com os artefatos produzidos em cada etapa: constituição do projeto, especificações, planos, tarefas, registros de revisão e código.

**O que não é.** Um jogo completo, nem um roteiro obrigatório da disciplina. Não trata de game design nem de arte; os gráficos são placeholders.

**Ferramenta usada na demonstração.** O fluxo foi executado com o **Claude Code**. Ele foi pensado para ser independente do agente: os artefatos são arquivos Markdown no repositório, e o Spec Kit, que organiza as etapas, oferece integração com vários agentes (Claude Code, Gemini CLI, GitHub Copilot, entre outros). **A execução com o Gemini CLI não foi verificada.** Verificar se o fluxo funciona com ele, e o que precisa ser adaptado, é o exercício proposto na seção 8.

## 2. A ideia central

Especificar bem **não impede** o agente de alucinar. A especificação reduz a ambiguidade, e com ela a margem para o agente inventar. Quem detecta a alucinação é a **verificação**: testes derivados dos critérios de aceitação e a leitura do código por um humano.

O fluxo se apoia em três elementos, e nenhum deles funciona sozinho:

1. **Especificação** com critérios de aceitação verificáveis.
2. **Passo pequeno**: cada tarefa termina com o jogo rodando e cabe numa revisão.
3. **Verificação humana** antes de aceitar cada passo.

A regra da disciplina vale aqui também: *você pode entregar código que a IA escreveu; não pode entregar código que não consegue explicar.*

## 3. Papéis

| Quem | Faz | Não faz |
|---|---|---|
| Humano | Escreve a constituição e as specs; responde às dúvidas do agente; revisa plano, tarefas e código; aceita ou rejeita cada passo; faz o commit | Aceitar código sem rodar e sem ler |
| Agente | Propõe plano e tarefas a partir da spec; implementa **uma** tarefa por vez; escreve os testes pedidos | Decidir escopo; mudar a spec; seguir para a próxima tarefa sem aprovação |

## 4. Camadas: o que depende do motor

| Camada | Arquivo | Depende do motor? | Conteúdo |
|---|---|---|---|
| Constituição | `.specify/memory/constitution.md` | Sim | Versão do motor, arquitetura, convenções, proibições |
| Especificação | `specs/NNN-*/spec.md` | **Não** | Comportamento observável e critérios de aceitação |
| Plano | `specs/NNN-*/plan.md` | Sim | Como a spec vira nós, cenas, scripts e testes |
| Tarefas | `specs/NNN-*/tasks.md` | Sim | Passos pequenos, cada um verificável |
| Afinação | `game/data/player_tuning.tres` | Formato sim, valores não | Números ajustados em playtest |

A separação entre **regra** e **afinação** é deliberada. "O pulo continua disponível por um curto intervalo depois de sair da borda" é regra: vai para a spec e vira teste. "Esse intervalo é de 0,1 s" é afinação: fica em arquivo de dados e muda no playtest sem reescrever a spec.

Um teste simples da separação de camadas: se uma spec cita `CharacterBody2D`, ela vazou implementação. A mesma spec deveria servir para gerar um plano no Unity (seção 9).

## 5. Ferramentas

Todas gratuitas.

| Ferramenta | Papel | Obrigatória? |
|---|---|---|
| Godot 4 (versão estável) | Motor | Sim |
| Git + GitHub | Histórico: um commit por tarefa aceita | Sim |
| [Spec Kit](https://github.com/github/spec-kit) (`specify` CLI) | Estrutura as etapas e gera os comandos do agente | Recomendada |
| Python 3.11+ e `uv` | Necessários para instalar o Spec Kit | Se usar o Spec Kit |
| Agente de IA (Claude Code, Gemini CLI, Copilot…) | Planeja e implementa | Sim |
| GUT (Godot Unit Test) | Testes dos critérios de aceitação, rodando sem abrir a janela | Sim |
| Servidor MCP para Godot (ex.: [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp)) | Permite ao agente rodar o projeto e ler a saída de depuração | Opcional |

Registre no `README.md` as versões exatas de Godot, Spec Kit e GUT usadas. As opções de linha de comando do Spec Kit mudaram entre versões: o que está escrito abaixo corresponde à documentação da versão 1.x.

## 6. Tutorial passo a passo

Cada passo traz o que o humano faz, o que o agente faz e o que conferir. Os blocos **Registro da execução** são preenchidos durante a execução real da demonstração; eles documentam o que aconteceu de fato, incluindo os erros do agente.

### Passo 0 — Preparar o ambiente

1. Instalar o Godot 4 e confirmar que ele roda pela linha de comando (`godot --version`).
2. Instalar o `uv` e o Spec Kit, fixando a versão:

   ```bash
   uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z
   specify version
   specify check
   ```

3. Instalar e autenticar o agente escolhido.

> **Registro da execução.** Versões usadas: Godot 4.7.2.stable.official · Spec Kit 1.0.10 · GUT 9.7.1 · agente Claude Code (modelo Sonnet 5).

### Passo 1 — Criar o repositório e iniciar o Spec Kit

```bash
git clone <repositório> ze-peixeira && cd ze-peixeira
specify init --here --integration claude     # ou: --integration gemini
```

O `init` cria `.specify/` (modelos e scripts) e os comandos do agente (`.claude/skills/` no Claude Code, `.gemini/commands/` no Gemini CLI). Ele **preserva** uma constituição existente em `.specify/memory/constitution.md`. Por isso, a constituição deste repositório não é sobrescrita.

Em seguida, criar o projeto Godot dentro de `game/` e instalar o GUT pelo AssetLib.

**Conferir:** `git status` mostra só arquivos do Spec Kit e do projeto Godot. Fazer o commit desse estado inicial antes de qualquer código gerado.

### Passo 2 — Constituição

A constituição é escrita pelo humano; o agente não a altera. Ela fixa o que vale para todas as fatias: versão do motor, APIs proibidas, arquitetura, convenções de nomes, como testar, o contrato dos placeholders e os padrões do Nystrom que devem aparecer.

Com o comando `/speckit.constitution`, o agente pode revisá-la e apontar lacunas. **Toda mudança sugerida é lida e aceita linha a linha**, ou rejeitada.

**Conferir:** cada regra da constituição pode ser verificada numa revisão de código? Uma regra que ninguém consegue conferir ("código limpo") não vale nada.

### Passo 3 — Especificação da fatia

Cada fatia tem uma `spec.md` escrita pelo humano em `specs/NNN-nome/`. A spec descreve o que o jogador vê e faz, nunca como implementar.

Para que os comandos do Spec Kit trabalhem sobre uma spec já existente, é preciso indicar a fatia ativa **antes de abrir o agente**:

```bash
export SPECIFY_FEATURE=001-movimento
```

Depois, rodar `/speckit.clarify`. O agente faz até cinco perguntas sobre pontos ambíguos, e as respostas voltam para a spec.

**Conferir:**

- Cada requisito tem ao menos um cenário de aceitação.
- Os critérios são observáveis e dá para dizer "passou" ou "não passou".
- A seção **Fora do escopo** existe e está preenchida. É ela que impede o agente de adiantar a próxima fatia.

> **Registro da execução.** Perguntas feitas pelo agente e decisões tomadas: ___

### Passo 4 — Plano

Rodar `/speckit.plan`. O agente gera `plan.md` (e, dependendo da fatia, `research.md` e `data-model.md`) a partir da spec e da constituição.

**Conferir no plano:**

- [ ] Usa só APIs do Godot 4, sem nada da lista proibida da constituição.
- [ ] As regras de decisão estão em classes puras e testáveis, separadas do nó de física.
- [ ] Cada padrão de projeto usado é **nomeado e justificado** ("State, porque…").
- [ ] Os parâmetros de afinação estão no recurso `PlayerTuning`, não no código.
- [ ] Nada do que está em *Fora do escopo* aparece no plano.

Se o plano falhar em algum item, a correção é pedida ao agente citando o item. Não se edita o plano à mão para "consertar rápido": a correção precisa ficar registrada.

> **Registro da execução.** Problemas encontrados no plano e como foram corrigidos: ___

### Passo 5 — Tarefas

Rodar `/speckit.tasks` para gerar `tasks.md` e, em seguida, `/speckit.analyze`. Esse segundo comando só lê: aponta inconsistências entre spec, plano e tarefas.

**Conferir:**

- [ ] Cada tarefa termina com o jogo rodando ou com testes passando.
- [ ] Cada tarefa cabe numa revisão (como referência, até cerca de 100 linhas alteradas).
- [ ] Os testes de cada requisito vêm antes ou junto da implementação, nunca "no fim".

### Passo 6 — Implementar uma tarefa por vez

Por padrão, `/speckit.implement` executa todas as tarefas. Neste fluxo, pede-se explicitamente uma por vez:

```
/speckit.implement Execute somente a tarefa T001. Pare ao terminar e resuma o que mudou.
```

Se o agente não respeitar o limite, o pedido é refeito em linguagem natural, citando a tarefa e o arquivo `tasks.md`.

Depois de cada tarefa, o humano:

1. Roda os testes sem abrir a janela:

   ```bash
   godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
   ```

2. Roda o jogo e testa com o controle na mão.
3. Lê o diff inteiro (`git diff`) com o checklist `docs/checklists/revisao-tarefa.md`.
4. Aceita ou rejeita. Aceitou: commit com a tarefa na mensagem (`T003: coyote time`). Rejeitou: descreve o problema ao agente e volta ao item 1.

Com um servidor MCP de Godot configurado, o agente pode rodar o projeto e ler os erros sozinho. Isso reduz as idas e vindas, mas **não substitui** os itens 2 e 3.

### Passo 7 — Registro de revisão

Toda tarefa em que o agente errou gera um registro em `docs/review/`, com base em `docs/review/_modelo.md`: o que foi pedido, o que veio, como o erro foi percebido e o que mudou (código, tarefa ou spec).

Esses registros são o artefato mais importante do repositório. Sem eles, o processo parece não ter atrito, e o papel do humano desaparece.

### Passo 8 — Fechar a fatia

1. Rodar `/speckit.converge`, que confere o código contra spec, plano e tarefas e acrescenta uma seção de convergência em `tasks.md`.
2. Fazer o playtest. Um ajuste de sensação ("pulo curto demais") muda o `player_tuning.tres`. Um ajuste de regra ("deveria dar para pular na parede") **volta para a spec**, nunca direto para o código.
3. Confirmar que todos os testes das fatias anteriores continuam passando.

### Passo 9 — Próxima fatia

```bash
export SPECIFY_FEATURE=002-pulo
```

E repetir a partir do Passo 3.

## 7. As fatias do Zé Peixeira

| Fatia | Mecânica | Padrão (Nystrom) em foco |
|---|---|---|
| 001-movimento | Corrida com aceleração e desaceleração, gravidade, queda máxima | Update Method (`_physics_process`), Game Loop (do motor) |
| 002-pulo | Altura variável, coyote time, jump buffer | Regras em classe pura, separadas do nó |
| 003-maquina-de-estados | Refatoração do controlador para estados explícitos | **State** |
| 004-dash-gibao | Dash em 8 direções; o gibão de couro protege dos espinhos durante o dash | State (novo estado), Observer (sinal de morte) |
| 005-peixeira-arremesso | Peixeira arremessada crava na parede e vira apoio; só uma por vez | Component, Observer |
| 006-corte-mandacaru | Corte com a peixeira abre caminho pelo mandacaru | Component (hitbox), State |

A fatia 003 vem depois de 001 e 002 de propósito. O controlador cresce com condicionais até ficar difícil de mexer, e a refatoração para State é pedida na spec com justificativa, com os testes das fatias anteriores servindo de rede de segurança.

O padrão **Command** não é usado: nenhuma mecânica precisa de reexecução ou de desfazer. Forçar um padrão sem necessidade também é um erro de projeto.

Os valores iniciais de afinação são inspirados no controlador de *Celeste*, cujo código do jogador (`Player.cs`) foi publicado pelos desenvolvedores. Eles são ponto de partida, não requisito.

## 8. Exercício: o fluxo funciona com o Gemini CLI?

O fluxo foi executado com o Claude Code. Para verificar com o Gemini CLI:

1. Clonar o repositório numa pasta nova e voltar ao ponto de partida da demonstração: `git checkout specs-v1`. Essa tag marca o commit que tem só a constituição e as specs, antes da configuração do agente e de qualquer código.
2. Rodar `specify init --here --integration gemini`.
3. Executar os Passos 3 a 8 para a fatia 001.
4. Registrar:
   - os comandos `/speckit.*` apareceram e funcionaram?
   - o agente respeitou a constituição, em especial as APIs proibidas do Godot 3?
   - o agente parou depois de uma tarefa quando pedido?
   - o que precisou ser adaptado (no pedido, na constituição, na spec)?
5. Comparar o plano gerado com o `plan.md` da demonstração. Diferenças de plano são esperadas; diferenças de **comportamento** (critérios de aceitação) não deveriam existir.

## 9. Adaptar para outro motor

A spec não muda. Mudam a constituição e, por consequência, o plano e as tarefas. No Unity, por exemplo:

| Godot | Unity |
|---|---|
| `CharacterBody2D` + `move_and_slide()` | `Rigidbody2D` cinemático ou `CharacterController` próprio |
| Nós filhos como componentes | `MonoBehaviour`s no mesmo `GameObject` |
| Sinais | Eventos C# ou `UnityEvent` |
| `Resource` (`.tres`) para afinação | `ScriptableObject` |
| GUT | Unity Test Framework |

## 10. Estrutura do repositório

```
ze-peixeira/
├── README.md                        # o que é, versões usadas, por onde começar
├── docs/
│   ├── fluxo-sdd.md                 # este documento
│   ├── apostila-sdd-ze-peixeira.docx  # este documento em formato de apostila
│   ├── checklists/
│   │   └── revisao-tarefa.md        # checklist usado em cada revisão de tarefa
│   └── review/
│       ├── _modelo.md               # modelo de registro de revisão
│       └── NNN-TXXX-*.md            # registros reais, um por tarefa com problema
├── .specify/
│   └── memory/
│       └── constitution.md          # constituição (escrita pelo humano)
├── specs/
│   ├── 001-movimento/               # spec (humano) · plan, tasks (agente)
│   ├── 002-pulo/
│   ├── 003-maquina-de-estados/
│   ├── 004-dash-gibao/
│   ├── 005-peixeira-arremesso/
│   └── 006-corte-mandacaru/
├── tools/apostila/                  # gera a apostila .docx a partir dos arquivos Markdown
└── game/                            # projeto Godot 4
    ├── project.godot
    ├── addons/gut/                  # instalado pelo AssetLib
    ├── data/player_tuning.tres      # afinação
    ├── scenes/                      # jogador, fase de teste, obstáculos
    ├── scripts/
    │   ├── regras/                  # classes puras, sem física (testáveis)
    │   ├── jogador/                 # nó do jogador e estados
    │   ├── data/                    # player_tuning.gd (class_name PlayerTuning)
    │   └── mundo/                   # espinhos, mandacaru, peixeira
    └── tests/                       # testes GUT, um arquivo por fatia
```

A tag `specs-v1` marca o estado do repositório antes da execução: só constituição, specs, checklist e modelos. O `specify init` acrescenta a `.specify/` os diretórios `templates/` e `scripts/`, e cria a pasta de comandos do agente. Esses arquivos podem ser versionados, para que outra pessoa reproduza o fluxo com a mesma versão.

## 11. Limites conhecidos

- **Sensação não se especifica em texto.** "O pulo parece pesado" não é critério de aceitação. Por isso a afinação fica fora da spec, e o playtest com placeholders só valida regras, não sensação.
- **A spec envelhece** se as mudanças forem direto para o código. A disciplina do Passo 8 (regra nova volta para a spec) é o que a mantém viva.
- **Custo.** Para uma mecânica pequena, constituição, spec e plano podem custar mais que o código. O método se paga à medida que as mecânicas interagem entre si: dash com espinhos, peixeira com parede, corte com peixeira arremessada.
- **Revisar exige saber ler o código.** O checklist ajuda, mas não substitui entender GDScript e a API do Godot.
