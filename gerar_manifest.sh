#!/bin/bash
# ============================================================
#  ODONTOLOGIA BERRO — Gerador de playlist
#  Compatível com: macOS, Linux
#  Uso:
#    1. Abra o Terminal
#    2. Arraste este arquivo para o Terminal e pressione Enter
#       OU execute: bash gerar_manifest.sh
# ============================================================

# Pasta onde este script está localizado
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASTA="$DIR/programacao"
MANIFEST="$DIR/manifest.json"
PLAYLISTJS="$DIR/playlist.js"

echo ""
echo "  +--------------------------------------------------+"
echo "  |   ODONTOLOGIA BERRO -- Gerador de playlist       |"
echo "  +--------------------------------------------------+"
echo ""

# Verifica se a pasta /programacao existe
if [ ! -d "$PASTA" ]; then
    echo "  [ERRO] Pasta não encontrada: $PASTA"
    echo "  Crie a pasta 'programacao' ao lado deste script"
    echo "  e coloque os vídeos MP4 dentro dela."
    echo ""
    exit 1
fi

echo "  Pasta : $PASTA"
echo "  Lendo arquivos de vídeo..."
echo ""

# Lista arquivos de vídeo (case-insensitive, sem duplicatas)
VIDEOS=()
while IFS= read -r -d '' file; do
    VIDEOS+=("$(basename "$file")")
done < <(find "$PASTA" -maxdepth 1 -type f \
    \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.webm" \
       -o -iname "*.m4v" -o -iname "*.mkv" \) \
    -print0 | sort -z)

COUNT=${#VIDEOS[@]}

if [ "$COUNT" -eq 0 ]; then
    echo "  [AVISO] Nenhum vídeo encontrado em: $PASTA"
    echo "  Formatos aceitos: .mp4  .mov  .webm  .m4v  .mkv"
    echo ""
    exit 1
fi

# Exibe lista
for i in "${!VIDEOS[@]}"; do
    echo "    [$((i+1))] ${VIDEOS[$i]}"
done

echo ""
echo "  Total: $COUNT arquivo(s)"
echo "  Gerando manifest.json e playlist.js..."
echo ""

# ============================================================
# Gera manifest.json e playlist.js via Python 3 (preferido)
# ============================================================
if command -v python3 &>/dev/null; then
    python3 - "$PASTA" "$MANIFEST" "$PLAYLISTJS" << 'PYEOF'
import os, json, sys

pasta, mf, jf = sys.argv[1], sys.argv[2], sys.argv[3]
exts = ('.mp4', '.mov', '.webm', '.m4v', '.mkv')
files = sorted(
    [x for x in os.listdir(pasta) if x.lower().endswith(exts)],
    key=str.lower
)

# manifest.json
with open(mf, 'w', encoding='utf-8') as f:
    json.dump({
        '_info':  'Gerado por gerar_manifest.sh',
        '_total': len(files),
        'files':  files
    }, f, ensure_ascii=False, indent=2)

# playlist.js (funciona em file:// sem servidor)
with open(jf, 'w', encoding='utf-8') as f:
    f.write('window.PLAYLIST_FILES=' + json.dumps(files, ensure_ascii=False) + ';')

print(f"  OK: {len(files)} vídeo(s) processado(s)")
PYEOF

else
    # ============================================================
    # Fallback: gera via bash puro (sem Python)
    # ============================================================
    echo "  [INFO] Python3 não encontrado. Gerando via bash puro..."

    # manifest.json
    {
        echo "{"
        echo "  \"_info\": \"Gerado por gerar_manifest.sh\","
        echo "  \"_total\": $COUNT,"
        echo "  \"files\": ["
        for i in "${!VIDEOS[@]}"; do
            if [ "$i" -eq 0 ]; then
                echo "    \"${VIDEOS[$i]}\""
            else
                echo "   ,\"${VIDEOS[$i]}\""
            fi
        done
        echo "  ]"
        echo "}"
    } > "$MANIFEST"

    # playlist.js
    {
        printf 'window.PLAYLIST_FILES=['
        for i in "${!VIDEOS[@]}"; do
            if [ "$i" -eq 0 ]; then
                printf '"%s"' "${VIDEOS[$i]}"
            else
                printf ',"%s"' "${VIDEOS[$i]}"
            fi
        done
        printf '];'
    } > "$PLAYLISTJS"
fi

# ============================================================
# Verifica e exibe resultado
# ============================================================
if [ ! -f "$PLAYLISTJS" ]; then
    echo "  [ERRO] Falha ao criar os arquivos."
    exit 1
fi

echo ""
echo "  +--------------------------------------------------+"
echo "  |   Arquivos gerados com sucesso!                  |"
echo "  +--------------------------------------------------+"
echo ""
echo "  manifest.json : $MANIFEST"
echo "  playlist.js   : $PLAYLISTJS"
echo "  Vídeos        : $COUNT arquivo(s)"
echo ""
echo "  Conteúdo do playlist.js:"
echo "  --------------------------------------------------"
cat "$PLAYLISTJS"
echo ""
echo "  --------------------------------------------------"
echo ""
echo "  ESTRUTURA DO PEN DRIVE:"
echo "    index.html"
echo "    playlist.js              <- funciona em file://"
echo "    manifest.json            <- funciona com servidor HTTP"
echo "    odontologia-berro.png"
echo "    gerar_manifest.sh        <- este script (Mac/Linux)"
echo "    gerar_manifest.bat       <- Windows"
echo "    programacao/"
echo "        video1.mp4"
echo "        video2.mp4 ..."
echo ""
echo "  Execute sempre que adicionar ou remover vídeos!"
echo ""
