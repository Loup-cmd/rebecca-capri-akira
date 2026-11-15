#!/bin/bash
# Préparation du ricing Rebecca-Capri-Akira (lancé par `ricing deps` et par
# transition.sh, sans sudo) : shader, premier rendu du thème, contrôle des polices.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
rca="$here/configs/config/rca"
shaders="$here/configs/config/quickshell/rca/shaders"

chmod +x "$rca"/bin/rca-* "$rca"/compat/omarchy-compat "$here/transition.sh"
mkdir -p "$HOME/.local/state/rca" "$HOME/Pictures/Screenshots" "$HOME/Videos/Recordings"

# Chemins propres à l'utilisateur (qt6ct ne développe pas « ~ »).
sed -i "s|^color_scheme_path=.*|color_scheme_path=$HOME/.config/qt6ct/colors/rca.conf|" "$here/configs/config/qt6ct/qt6ct.conf"
# Marque-pages Nautilus partagés avec le ricing default de hypr-switch, s'il existe.
bookmarks="$here/configs/config/gtk-3.0/bookmarks"
if [[ ! -e "$bookmarks" && -f "$here/../default/configs/config/gtk-3.0/bookmarks" ]]; then
  ln -s ../../../../default/configs/config/gtk-3.0/bookmarks "$bookmarks"
fi

# Le shader CRT est fourni compilé ; il est recompilé quand l'outil Qt est là.
if [[ -x /usr/lib/qt6/bin/qsb ]]; then
  /usr/lib/qt6/bin/qsb --qt6 -o "$shaders/crt.frag.qsb" "$shaders/crt.frag" && echo "  shader CRT compilé"
fi

"$rca/bin/rca-theme" auto
"$rca/bin/rca-theme" apply
"$rca/bin/rca-theme" status

fc-cache -f >/dev/null 2>&1 || true
fonts="$(fc-list : family)"
for font in "IBM Plex Sans Condensed" "IBM Plex Serif" "ShureTechMono Nerd Font" "JetBrainsMono Nerd Font"; do
  if grep -qiF "$font" <<<"$fonts"; then
    echo "  police OK : $font"
  else
    echo "  police manquante : $font (paquets : ttf-ibm-plex, ttf-sharetech-mono-nerd)" >&2
  fi
done
