# Revisão 000-P1 — conclusão errada sobre um bug no GUT

**Fatia:** 000-ambiente · **Tarefa:** P1 (Passo 0/1 — instalar e ativar o GUT) · **Agente e modelo:** Claude Code, Sonnet 5 · **Data:** 2026-09-22

## O que foi pedido

Trecho da instrução do humano (Passo 0/1, item 4):

> Instale o GUT (release oficial compatível com a versão do Godot) em `game/addons/gut`, ative o plugin e crie um teste trivial em `game/tests/`.

## O que veio

O agente instalou o GUT v9.7.1 (clone raso da tag `v9.7.1` de `bitwes/Gut`) em `game/addons/gut`, mas **não ativou o plugin**. A justificativa dada ao humano foi: `game/addons/gut/menu_manager.gd` está ausente do pacote (só existe `menu_manager.gd.uid`, confirmado com `gh api` em várias tags e no `HEAD` de `main`), e `gut_plugin.gd` chamaria `MenuManager.new()` na linha 90, o que quebraria a ativação do plugin no editor. O agente recomendou instalar sem ativar e prosseguir só com a CLI (`gut_cmdln.gd`).

## Problema

Tipo:

- [ ] API inexistente ou do Godot 3
- [ ] Violação da constituição (qual item: ___)
- [ ] Critério de aceitação não atendido (qual: ___)
- [ ] Escopo além da tarefa ou da spec
- [ ] Teste que não testa o critério
- [ ] Ambiguidade da spec (o agente não errou; a spec permitia essa leitura)
- [x] Outro: diagnóstico sem verificar referências

Descrição: o agente leu `var _menu_mgr = null` e `_menu_mgr = MenuManager.new()` em `gut_plugin.gd` e presumiu que `MenuManager` era uma classe global (`class_name MenuManager`) declarada em `menu_manager.gd`, sem checar como o identificador `MenuManager` era de fato definido no próprio arquivo. Bastava rodar `grep -rn "menu_manager.gd\|gut_menu.gd" game/addons/gut/gut_plugin.gd` para ver a linha 5:

```
var MenuManager = load("res://addons/gut/gut_menu.gd")
```

`MenuManager` é uma variável local do plugin que carrega `gut_menu.gd` (arquivo presente e íntegro) por caminho explícito — não uma classe global. O arquivo `menu_manager.gd.uid` órfão (sem `.gd` correspondente) é resíduo de uma renomeação antiga no repositório upstream, sem nenhuma referência no addon. Não há bug de empacotamento no GUT.

## Como foi percebido

- [ ] Teste falhou
- [ ] Jogando
- [ ] Lendo o diff
- [ ] Console do Godot
- [x] Outro: revisão humana — o humano pediu o grep de verificação (`grep -rn "menu_manager.gd\|gut_menu.gd" game/addons/gut/gut_plugin.gd`) e apontou o erro antes de a fatia 001 começar.

## O que mudou

- [x] Só o código (pedido de correção ao agente)
- [ ] A tarefa (`tasks.md`)
- [ ] A spec (`spec.md`), por decisão humana
- [ ] A constituição

Pedido de correção enviado, copiado literalmente:

> A. GUT — sua conclusão sobre o bug está errada. Verifique você mesmo: `grep -rn "menu_manager.gd\|gut_menu.gd" game/addons/gut/gut_plugin.gd`. O plugin carrega gut_menu.gd (que existe); menu_manager.gd.uid é um arquivo órfão de renomeação, sem referências. 1. Confirme isso com o grep e me mostre a saída. 2. Ative o plugin em game/project.godot ([editor_plugins] enabled=PackedStringArray("res://addons/gut/plugin.cfg")). 3. Rode `godot --headless --path game --editor --quit` e me mostre qualquer erro ou aviso relacionado ao GUT. Rode também os testes pela CLI de novo. 4. Não apague o .uid órfão: é arquivo do pacote upstream.

Resultado da correção: `[editor_plugins] enabled=PackedStringArray("res://addons/gut/plugin.cfg")` adicionado a `game/project.godot`; `godot --headless --path game --editor --quit` rodou sem nenhum erro ou aviso relacionado a GUT; `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` continuou com `1/1 passed`.

## Lição

Antes de declarar um bug numa dependência, verificar quem referencia o arquivo supostamente ausente — um `grep` no ponto de uso custa segundos e teria evitado a conclusão errada e a decisão (também errada) de não ativar o plugin.
