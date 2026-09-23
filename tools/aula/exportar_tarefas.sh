#!/usr/bin/env bash
# Exporta cada tag fatiaNNN-TXXX do repositório para uma pasta standalone,
# fora do repositório, para uso em aula: cada pasta é um snapshot jogável
# do estado do projeto exatamente ao final daquela tarefa aceita.
#
# Uso: tools/aula/exportar_tarefas.sh [--forcar]
#   --forcar   sobrescreve pastas de exportação já existentes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEST_ROOT="$(cd "$REPO_ROOT/.." && pwd)/ze-peixeira-aula"

FORCAR=false
for arg in "$@"; do
    case "$arg" in
        --forcar) FORCAR=true ;;
        *)
            echo "Uso: $0 [--forcar]" >&2
            exit 1
            ;;
    esac
done

cd "$REPO_ROOT"

TAGS=()
while IFS= read -r tag; do
    [ -n "$tag" ] && TAGS+=("$tag")
done < <(git tag -l 'fatia*-T*' | sort -V)

if [ ${#TAGS[@]} -eq 0 ]; then
    echo "Nenhuma tag fatia*-T* encontrada no repositório." >&2
    exit 1
fi

mkdir -p "$DEST_ROOT"

CRIADAS=()

for tag in "${TAGS[@]}"; do
    dest="$DEST_ROOT/$tag"

    if [ -e "$dest" ]; then
        if [ "$FORCAR" = true ]; then
            rm -rf "$dest"
        else
            echo "Aviso: '$dest' já existe — pulando (use --forcar para sobrescrever)." >&2
            continue
        fi
    fi

    mkdir -p "$dest"
    git archive "$tag" | tar -x -C "$dest"

    # Fatia (NNN) e tarefa (TXXX) a partir do nome da tag (fatiaNNN-TXXX) —
    # as tarefas recomeçam em T001 a cada fatia, então o nome precisa das duas.
    prefixo_fatia="${tag%-*}"
    tarefa="${tag##*-}"
    fatia_num="${prefixo_fatia#fatia}"

    project_file="$dest/game/project.godot"
    if [ -f "$project_file" ]; then
        sed -i.bak "s|^config/name=.*|config/name=\"Zé Peixeira — fatia ${fatia_num} · ${tarefa}\"|" "$project_file"
        rm -f "$project_file.bak"
    else
        echo "Aviso: '$project_file' não encontrado em '$tag' — config/name não alterado." >&2
    fi

    CRIADAS+=("$dest")
    echo "Exportado: $tag -> $dest"
done

echo ""
echo "Pastas criadas:"
if [ ${#CRIADAS[@]} -gt 0 ]; then
    for pasta in "${CRIADAS[@]}"; do
        echo "  - $pasta"
    done
else
    echo "  (nenhuma — todas as pastas já existiam; use --forcar para regenerar)"
fi
echo ""
echo "Para usar em aula: abra o Godot Engine, escolha 'Importar' e selecione o game/project.godot de cada pasta acima."
