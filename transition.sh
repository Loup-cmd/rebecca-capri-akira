#!/bin/bash
# Rebecca-Capri-Akira — transition complète, d'Omarchy à Arch + ce ricing.
#
#   ./transition.sh             lance (ou reprend) la transition
#   ./transition.sh --dry-run   montre tout ce qui serait fait, sans rien modifier
#   ./transition.sh --status    étape atteinte
#
# Sept étapes ; chacune est annoncée et attend ton accord. La progression est
# mémorisée : après le redémarrage demandé à l'étape 6, relance simplement le
# script, il reprend à l'étape 7. Tes fichiers et projets ne sont pas touchés ;
# chaque fichier de config modifié est sauvegardé avant.
#
#   1 Préparer      paquets Arch du ricing, polices, premier rendu du thème
#   2 Basculer      ricing switch, puis tu valides le bureau
#   3 Applis        bash, Neovim, btop, VS Code, Firefox, web apps sur le thème
#   4 Autres rices  sekaipop rendu indépendant d'Omarchy
#   5 Socle Arch    instantané de secours, noyau linux, greetd, quickshell d'Arch
#   6 Retrait       paquets Omarchy retirés, réglages de démarrage conservés
#   7 Nettoyage     (après redémarrage) noyau et dépôt Omarchy retirés
set -uo pipefail

NAME="Rebecca-Capri-Akira"
ROOT="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
RCA="$ROOT/configs/config/rca"
STATE="$HOME/.local/state/rca"
STEP_FILE="$STATE/transition.step"
SAVE_FILE="$STATE/transition.save"
SHARE="$HOME/.local/share/rca"
BACKUP="$HOME/.local/share/hypr-switch-backups/transition-$(date +%Y%m%d-%H%M%S)"
OMARCHY_PKGS=(omarchy omarchy-settings omarchy-themes-intros omarchy-hyprland-titlebars omarchy-speedtest omarchy-nvim)
DRY=0

case "${1:-}" in
  --dry-run) DRY=1 ;;
  --status) echo "Dernière étape terminée : $(cat "$STEP_FILE" 2>/dev/null || echo 0) / 7"; exit 0 ;;
  "") ;;
  *) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac

# ───────────────────────────────────────────────────────────── outils
O=$'\033[1;38;2;247;77;19m'; D=$'\033[2m'; R=$'\033[1;31m'; N=$'\033[0m'
mkdir -p "$STATE"
DONE="$(cat "$STEP_FILE" 2>/dev/null || echo 0)"
(( DRY )) && DONE=0

title() { printf '\n%s━━ Étape %s/7 — %s%s\n' "$O" "$1" "$2" "$N"; }
info() { printf '   %s\n' "$*"; }
warn() { printf '   %s%s%s\n' "$R" "$*" "$N"; }
die() { warn "$*"; exit 1; }
# act "description" : vrai s'il faut agir, faux en simulation.
act() {
  if (( DRY )); then printf '   %s→ %s%s\n' "$D" "$1" "$N"; return 1; fi
  printf '   • %s\n' "$1"
}
ask() {
  (( DRY )) && return 0
  local r
  read -rp "   $1 [o/N] " r
  [[ "$r" == [oOyY] ]]
}
todo() { (( DONE < $1 )); }
mark() { (( DRY )) || { echo "$1" > "$STEP_FILE"; DONE=$1; }; }
keep() {  # sauvegarde un fichier utilisateur avant modification
  [[ -e "$1" || -L "$1" ]] || return 0
  mkdir -p "$BACKUP$(dirname "$1")" && cp -a "$1" "$BACKUP$1"
}
have() { pacman -Qq "$1" >/dev/null 2>&1; }

[[ $EUID -ne 0 ]] || die "Lance ce script avec ton utilisateur, pas en root (il demandera sudo au besoin)."
command -v ricing >/dev/null || die "Commande « ricing » introuvable."
(( DRY )) && printf '%sSIMULATION — rien ne sera modifié.%s\n' "$O" "$N"
printf '%sRebecca-Capri-Akira%s — étapes déjà faites : %s/7\n' "$O" "$N" "$DONE"

# ───────────────────────────────────────────────────────────── 1
if todo 1; then
  title 1 "Préparer : paquets, polices, thème"
  ricing switch capture-status 2>&1 | grep -qi "no capture" || die "Une capture hypr-switch est en cours : termine-la d'abord."
  mapfile -t pkgs < <(sed -n 's/^packages=//p' "$ROOT/ricing.conf" | tr ' ' '\n' | grep .)
  info "Paquets (dépôts officiels Arch) : ${pkgs[*]}"
  ask "Installer ce qui manque ?" || exit 0
  if act "sudo pacman -S --needed ${#pkgs[@]} paquets"; then
    sudo pacman -S --needed --noconfirm "${pkgs[@]}" || die "Installation des paquets échouée."
  fi
  if act "setup.sh : polices, shader, premier rendu du thème jour/nuit"; then
    bash "$ROOT/setup.sh" || die "setup.sh a échoué."
  fi
  mark 1
fi

# ───────────────────────────────────────────────────────────── 2
if todo 2; then
  title 2 "Basculer sur le ricing"
  if [[ "$(ricing current 2>/dev/null)" != "$NAME" ]]; then
    info "Le bureau va changer sous tes yeux ; cette fenêtre reste ouverte."
    ask "Basculer maintenant ?" || exit 0
    if act "ricing switch $NAME"; then
      ricing switch "$NAME" || die "La bascule a échoué (hypr-switch est revenu en arrière)."
      sleep 4
    fi
  else
    info "Déjà actif."
  fi
  info "Vérifie : pupitre en bas (levier Utilitaires, batterie, horloge à tubes),"
  info "SUPER + ESPACE ouvre le menu, SUPER + ENTRÉE un terminal, SUPER + CTRL + L verrouille."
  if ! ask "Tout fonctionne et le résultat te convient ?"; then
    ask "Revenir sur Omarchy (ricing switch default) ?" && ricing switch default
    exit 0
  fi
  mark 2
fi

# ───────────────────────────────────────────────────────────── 3
if todo 3; then
  title 3 "Applis et shell sur le thème (sauvegardes : $BACKUP)"
  ask "Continuer ?" || exit 0

  if [[ -d /usr/share/omarchy/default/bash ]]; then
    if act "bash : copie locale des fichiers bash d'Omarchy → $SHARE/bash"; then
      mkdir -p "$SHARE" && rm -rf "$SHARE/bash" && cp -r /usr/share/omarchy/default/bash "$SHARE/bash"
      sed -i 's|\$OMARCHY_PATH/default/bash|'"$SHARE"'/bash|g; s|"\${OMARCHY_PATH:=/usr/share/omarchy}"|"'"$SHARE"'"|' "$SHARE"/bash/rc "$SHARE"/bash/functions "$SHARE"/bash/init
      sed -i '/env-bootstrap/d; s|^export EDITOR=.*|export EDITOR="${EDITOR:-nvim}"|; s|^export BROWSER=.*|export BROWSER="${BROWSER:-firefox}"|' "$SHARE/bash/envs"
      sed -i '/omarchy-agent/d' "$SHARE/bash/aliases"
    fi
  fi
  rc="$(readlink -f "$HOME/.bashrc")"
  if act "bash : ~/.bashrc charge la copie locale et les couleurs fzf du thème"; then
    keep "$rc"
    sed -i 's|^\[\[ -r /usr/share/omarchy/default/bash/env-bootstrap \]\] && source .*|# (rca) env-bootstrap Omarchy retiré|; s|^source "\$OMARCHY_PATH/default/bash/rc"|source "'"$SHARE"'/bash/rc"|' "$rc"
    grep -q "rca/theme/fzf.sh" "$rc" || printf '\n# Rebecca-Capri-Akira : couleurs fzf/bat du thème jour/nuit\n[[ -r ~/.local/state/rca/theme/fzf.sh ]] && source ~/.local/state/rca/theme/fzf.sh\n' >> "$rc"
  fi
  if act "session : variables posées jusque-là par Omarchy (~/.config/uwsm/env.d/20-rca)"; then
    mkdir -p "$HOME/.config/uwsm/env.d"
    cat > "$HOME/.config/uwsm/env.d/20-rca" <<'EOF'
# Rebecca-Capri-Akira : remplace /usr/share/uwsm/env.d/10-omarchy
export TERMINAL=kitty
export EDITOR=nvim
export BROWSER=firefox
command -v mise >/dev/null && eval "$(mise activate bash --shims)"
EOF
  fi
  if act "Neovim et btop : thème jour/nuit"; then
    keep "$HOME/.config/nvim/lua/plugins/theme.lua"
    ln -sfn "$HOME/.local/state/rca/theme/neovim.lua" "$HOME/.config/nvim/lua/plugins/theme.lua"
    mkdir -p "$HOME/.config/btop/themes"
    ln -sfn "$HOME/.local/state/rca/theme/btop.theme" "$HOME/.config/btop/themes/current.theme"
  fi
  if act "VS Code : thème local « Rebecca (RCA) »"; then
    ext="$HOME/.vscode/extensions/rca-theme"
    mkdir -p "$ext/themes" && ln -sfn "$HOME/.local/state/rca/theme/vscode-theme.json" "$ext/themes/rca.json"
    cat > "$ext/package.json" <<'EOF'
{"name":"rca-theme","displayName":"Rebecca (RCA)","publisher":"local","version":"1.0.0","engines":{"vscode":"^1.70.0"},"categories":["Themes"],"contributes":{"themes":[{"label":"Rebecca (RCA)","uiTheme":"vs-dark","path":"./themes/rca.json"}]}}
EOF
    list="$HOME/.vscode/extensions/extensions.json"
    if [[ -f "$list" ]]; then
      keep "$list"
      jq --arg p "$ext" 'map(select(.identifier.id != "local.rca-theme")) + [{identifier:{id:"local.rca-theme"},version:"1.0.0",location:{"$mid":1,fsPath:$p,external:("file://"+$p),path:$p,scheme:"file"},relativeLocation:"rca-theme"}]' "$list" > "$list.tmp" && mv "$list.tmp" "$list"
    fi
    settings="$HOME/.config/Code/User/settings.json"
    if [[ -f "$settings" ]]; then
      keep "$settings"
      sed -i 's|"workbench.colorTheme": *"[^"]*"|"workbench.colorTheme": "Rebecca (RCA)"|' "$settings"
    fi
  fi
  for profile in "$HOME"/.config/mozilla/firefox/*.default-release "$HOME"/.mozilla/firefox/*.default-release; do
    [[ -d "$profile" ]] || continue
    if act "Firefox : couleurs de l'interface ($(basename "$profile"))"; then
      keep "$profile/chrome/userChrome.css"; keep "$profile/user.js"
      mkdir -p "$profile/chrome" && touch "$profile/chrome/.rca"
      cp "$HOME/.local/state/rca/theme/firefox.css" "$profile/chrome/rca-colors.css"
      if ! grep -q "rca-colors.css" "$profile/chrome/userChrome.css" 2>/dev/null; then
        cat >> "$profile/chrome/userChrome.css" <<'EOF'
/* Rebecca-Capri-Akira — couleurs suivies par rca-theme */
@import url("rca-colors.css");
:root {
  --toolbar-bgcolor: var(--rca-bg) !important;
  --toolbar-color: var(--rca-fg) !important;
  --lwt-accent-color: var(--rca-bg-dark) !important;
  --tab-selected-bgcolor: var(--rca-bg-light) !important;
  --toolbar-field-background-color: var(--rca-bg-light) !important;
  --toolbar-field-color: var(--rca-fg) !important;
  --focus-outline-color: var(--rca-accent) !important;
  --tab-border-radius: 0 !important;
  --toolbarbutton-border-radius: 0 !important;
}
#navigator-toolbox { background: var(--rca-bg-dark) !important; }
.tab-background[selected] { border-top: 2px solid var(--rca-accent) !important; }
EOF
      fi
      grep -q legacyUserProfileCustomizations "$profile/user.js" 2>/dev/null || echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$profile/user.js"
    fi
  done
  if act "navigateur par défaut : Firefox ; web apps relancées par rca-webapp"; then
    xdg-settings set default-web-browser firefox.desktop 2>/dev/null || true
    for f in "$HOME"/.local/share/applications/*.desktop; do
      grep -q "omarchy-launch-webapp" "$f" 2>/dev/null || continue
      keep "$f"
      sed -i "s|omarchy-launch-webapp|$RCA/bin/rca-webapp|g" "$f"
    done
  fi
  act "thème appliqué aux applis" && "$RCA/bin/rca-theme" apply
  mark 3
fi

# ───────────────────────────────────────────────────────────── 4
if todo 4; then
  title 4 "sekaipop : ricing complet sans Omarchy"
  info "Sa keymap Omarchy est figée dans le ricing, et ses commandes omarchy-* sont"
  info "remplacées par config/rca/compat. Tant qu'Omarchy est là, rien ne change pour lui."
  if act "rca-freeze-keymap sekaipop"; then
    "$RCA/bin/rca-freeze-keymap" sekaipop || die "Impossible de figer la keymap de sekaipop."
  fi
  mark 4
fi

# ───────────────────────────────────────────────────────────── 5
if todo 5; then
  title 5 "Socle Arch : instantané, noyau, écran de connexion, quickshell"
  info "À partir d'ici le système est modifié (sudo). Un instantané btrfs est pris d'abord :"
  info "en cas de souci au démarrage, entrée « Snapshots » du menu Limine."
  (( DRY )) || [[ "$(ricing current 2>/dev/null)" == "$NAME" ]] || die "Le ricing actif n'est pas $NAME."
  ask "Continuer ?" || exit 0
  if act "instantané snapper « avant sortie d'Omarchy »"; then
    sudo snapper -c root create -d "avant sortie d'Omarchy ($NAME)" -c important \
      || { ask "Instantané impossible. Continuer SANS filet de sécurité ?" || exit 1; }
  fi
  if have omarchy-power-profiles-daemon && act "profils d'énergie : paquet Omarchy → paquet Arch"; then
    sudo pacman -Rdd --noconfirm omarchy-power-profiles-daemon || die "Retrait d'omarchy-power-profiles-daemon échoué."
  fi
  if act "sudo pacman -S linux greetd greetd-tuigreet power-profiles-daemon"; then
    sudo pacman -S --needed --noconfirm linux greetd greetd-tuigreet power-profiles-daemon || die "Installation échouée."
    sudo systemctl enable --now power-profiles-daemon.service >/dev/null 2>&1 || true
  fi
  info "(pendant le contrôle, un second pupitre apparaît quelques secondes : c'est normal)"
  if act "quickshell : version du dépôt Arch (extra), puis contrôle du shell"; then
    sudo pacman -S --noconfirm extra/quickshell || die "Installation de extra/quickshell échouée."
    log="$(mktemp)"
    env RCA_TEST=1 timeout 7 qs -p "$HOME/.config/quickshell/rca" > "$log" 2>&1
    if ! grep -qi "configuration loaded" "$log" || grep -qiE "is not a type|is not installed|failed to load" "$log"; then
      warn "Le shell ne se charge pas avec quickshell d'Arch : retour à la version précédente."
      sudo pacman -S --noconfirm omarchy/quickshell
      die "Transition arrêtée avant tout retrait. Journal : $log"
    fi
    rm -f "$log"
    info "shell chargé sans erreur avec quickshell $(pacman -Q quickshell | cut -d' ' -f2)"
  fi
  mark 5
fi

# ───────────────────────────────────────────────────────────── 6
if todo 6; then
  title 6 "Retrait d'Omarchy"
  info "Paquets retirés : ${OMARCHY_PKGS[*]}"
  info "Avant : sauvegarde des réglages système d'omarchy-settings (déverrouillage du disque"
  info "au démarrage, Limine, zram, veille…). Après : ils sont remis en place comme fichiers locaux."
  info "Le noyau linux-omarchy reste jusqu'au redémarrage (étape 7)."
  ask "Retirer Omarchy ?" || exit 0
  # Reprise après une interruption : la sauvegarde déjà faite est réutilisée.
  save="$(cat "$SAVE_FILE" 2>/dev/null || true)"
  if (( ! DRY )) && [[ -n "$save" ]] && sudo test -s "$save/files.tar"; then
    info "Sauvegarde existante réutilisée : $save"
  else
    save="/var/backups/omarchy-settings-$(date +%Y%m%d-%H%M%S)"
  fi
  if { (( DRY )) || ! sudo test -s "$save/files.tar"; } && act "sauvegarde → $save"; then
    echo "$save" > "$SAVE_FILE"
    sudo mkdir -p "$save"
    pacman -Qlq omarchy-settings | grep -v '/$' | grep -E '^/(etc|usr/lib)/' | grep -v '^/etc/skel/' > "$STATE/transition.files"
    sudo tar -cpf "$save/files.tar" --ignore-failed-read -T "$STATE/transition.files" 2>/dev/null
    sudo test -s "$save/files.tar" || die "Sauvegarde vide : arrêt, rien n'a été retiré."
    sudo cp -L /etc/fonts/conf.d/50-omarchy.conf "$save/50-fonts.conf" 2>/dev/null || true
  fi
  mapfile -t present < <(for p in "${OMARCHY_PKGS[@]}"; do have "$p" && echo "$p"; done)
  if (( ${#present[@]} )) && act "sudo pacman -R ${present[*]}"; then
    sudo pacman -R --noconfirm "${present[@]}" || die "pacman a refusé le retrait : rien d'autre n'a été modifié."
  fi
  if act "réglages système remis en place (initramfs, Limine, zram, logind, sysctl, udev, réseau)"; then
    sudo tar -xpf "$save/files.tar" -C / \
      --exclude='etc/sddm.conf.d/*' --exclude='etc/profile.d/omarchy.sh' --exclude='etc/xdg/kitty/*' \
      --exclude='etc/fastfetch/*' --exclude='etc/mpv/*' --exclude='etc/fonts/conf.d/50-omarchy.conf' \
      --exclude='etc/sudoers.d/omarchy-dns' --exclude='etc/sudoers.d/omarchy-theme-browser' \
      --exclude='etc/sudoers.d/omarchy-tzupdate' --exclude='etc/sudoers.d/omarchy-locale-generate' \
      --exclude='usr/lib/systemd/user/*' --exclude='usr/lib/environment.d/*' || die "Restauration échouée : NE REDÉMARRE PAS, relance le script."
    # Ce qui vivait dans /usr/lib passe dans /etc (rien d'orphelin dans /usr).
    sudo tar -tf "$save/files.tar" | grep '^usr/lib/systemd/' | grep -v '^usr/lib/systemd/user/' | while read -r f; do
      sudo test -f "/$f" || continue
      d="/etc/${f#usr/lib/}"
      sudo mkdir -p "$(dirname "$d")" && sudo mv "/$f" "$d"
    done
    sudo sed -i 's/^TARGET_OS_NAME=.*/TARGET_OS_NAME="Arch Linux"/; s/^BOOT_ORDER=.*/BOOT_ORDER="linux, linux-omarchy, *, *fallback, Snapshots"/' /etc/limine-entry-tool.d/omarchy-defaults.conf
    sudo test -f "$save/50-fonts.conf" && sudo cp "$save/50-fonts.conf" /etc/fonts/conf.d/50-local.conf && fc-cache -f
  fi
  if act "écran de connexion : SDDM → greetd (ouverture de session automatique conservée)"; then
    sudo mkdir -p /etc/greetd
    sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

# Ouverture de session automatique au démarrage, comme avant
# (le mot de passe du disque chiffré protège déjà la machine).
[initial_session]
command = "uwsm start -g -1 -e -D Hyprland hyprland.desktop"
user = "$USER"

# Après une déconnexion : écran de connexion texte.
[default_session]
command = "tuigreet --time --remember --asterisks --greeting 'REBECCA CAPRI AKIRA' --cmd 'uwsm start -g -1 -e -D Hyprland hyprland.desktop'"
user = "greeter"
EOF
    sudo systemctl disable sddm.service >/dev/null 2>&1
    sudo systemctl enable greetd.service || die "Activation de greetd échouée : NE REDÉMARRE PAS (sudo systemctl enable sddm pour revenir)."
  fi
  if act "services utilisateur d'Omarchy désactivés"; then
    for link in "$HOME"/.config/systemd/user/*.wants/omarchy-*.service "$HOME"/.config/systemd/user/*.wants/owed.service; do
      [[ -L "$link" ]] && systemctl --user disable "$(basename "$link")" >/dev/null 2>&1
    done
  fi
  if act "Plymouth (thème bgrt), initramfs et entrées Limine reconstruits"; then
    command -v plymouth-set-default-theme >/dev/null && sudo plymouth-set-default-theme bgrt
    sudo limine-mkinitcpio || die "Reconstruction échouée : NE REDÉMARRE PAS, relance le script."
    conf="$(sudo find /boot -maxdepth 3 -name limine.conf 2>/dev/null | head -n1)"
    if [[ -n "$conf" ]]; then
      info "Entrées de démarrage :"
      sudo grep -E '^\s*/+[^/]' "$conf" | sed 's/^/      /' | head -12
      sudo grep -qE 'linux([^-a-z]|$)' "$conf" || warn "Aucune entrée « linux » (noyau Arch) repérée : vérifie la liste avant de redémarrer."
    fi
  fi
  mark 6
  printf '\n%sRedémarrage nécessaire.%s Le noyau Arch démarre par défaut ; relance ensuite ce script pour l'\''étape 7.\n' "$O" "$N"
  info "Si l'écran de connexion ne vient pas : CTRL + ALT + F2, ouvre une session, puis"
  info "« sudo systemctl disable greetd » et « uwsm start hyprland.desktop »."
  if ask "Redémarrer maintenant ?"; then (( DRY )) || systemctl reboot; fi
  (( DRY )) || exit 0
fi

# ───────────────────────────────────────────────────────────── 7
if todo 7; then
  title 7 "Nettoyage après redémarrage"
  if uname -r | grep -q omarchy; then
    (( DRY )) || die "Tu tournes encore sur le noyau Omarchy ($(uname -r)). Redémarre et choisis l'entrée « linux » dans Limine."
  fi
  info "Noyau en service : $(uname -r)"
  ask "Retirer le noyau et le dépôt Omarchy ?" || exit 0
  mapfile -t kernel < <(for p in linux-omarchy linux-omarchy-headers; do have "$p" && echo "$p"; done)
  if (( ${#kernel[@]} )) && act "sudo pacman -R ${kernel[*]}"; then
    sudo pacman -R --noconfirm "${kernel[@]}" || die "Retrait du noyau échoué."
    sudo sed -i 's/^BOOT_ORDER=.*/BOOT_ORDER="linux, *, *fallback, Snapshots"/' /etc/limine-entry-tool.d/omarchy-defaults.conf
    sudo limine-mkinitcpio || warn "limine-mkinitcpio a échoué : relance « sudo limine-mkinitcpio » avant de redémarrer."
  fi
  if grep -q '^\[omarchy\]' /etc/pacman.conf && act "dépôt [omarchy] retiré de /etc/pacman.conf (copie : pacman.conf.omarchy.bak)"; then
    sudo cp /etc/pacman.conf /etc/pacman.conf.omarchy.bak
    sudo sed -i '/^\[omarchy\]/,/^\[/{/^\[omarchy\]/d;/^\[/!d}' /etc/pacman.conf
    sudo pacman -Sy
    have omarchy-keyring && sudo pacman -R --noconfirm omarchy-keyring
  fi
  if grep -q '^ID=omarchy' /etc/os-release 2>/dev/null && act "identité du système : Arch Linux (/etc/os-release)"; then
    sudo cp -a /etc/os-release /etc/os-release.omarchy.bak
    sudo ln -sfn ../usr/lib/os-release /etc/os-release
  fi
  mark 7
  printf '\n%sTerminé : Arch + Rebecca-Capri-Akira, sans Omarchy.%s\n' "$O" "$N"
  info "Paquets venus du dépôt Omarchy, désormais sans mises à jour : pacman -Qm"
  info "Ne bascule plus sur « default » (son interface était Omarchy). sekaipop reste utilisable."
  info "Restes sans effet, à supprimer quand tu veux : ~/.local/state/omarchy, ~/.local/share/omarchy, paquet sddm."
else
  info "Transition déjà terminée."
fi
