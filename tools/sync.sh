#!/bin/bash
# Recopie le ricing installé (hypr-switch) dans ce dépôt, sans rien de propre à la
# machine : liens vers d'autres ricings, couleurs générées, chemins absolus.
#   tools/sync.sh [dossier du ricing]
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
src="${1:-$HOME/.hypr-switch/shells/Rebecca-Capri-Akira}"
[[ -f "$src/ricing.conf" ]] || { echo "ricing introuvable : $src" >&2; exit 1; }

rsync -a --delete \
  --exclude '/configs/config/gtk-3.0/bookmarks' \
  --exclude 'rca-colors.css' \
  --exclude '/configs/config/qt6ct/colors/' \
  --exclude '/configs/config/rca/user.lua' \
  "$src/configs/" "$repo/configs/"
cp "$src/ricing.conf" "$src/setup.sh" "$src/transition.sh" "$src/MIGRATION.md" "$repo/"
sed -i 's|^color_scheme_path=.*|color_scheme_path=~/.config/qt6ct/colors/rca.conf|' "$repo/configs/config/qt6ct/qt6ct.conf"

if grep -rIl "/home/$USER" "$repo/configs" "$repo"/*.sh "$repo"/*.md "$repo/ricing.conf" 2>/dev/null | grep -v emojis.json; then
  echo "Chemins personnels trouvés ci-dessus : à corriger avant de publier." >&2
  exit 1
fi
echo "Synchronisé depuis $src"
