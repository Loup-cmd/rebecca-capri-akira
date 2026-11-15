# Fonctions partagées par les scripts rca-* (à sourcer, pas à exécuter).

RCA_HOME="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
RCA_BIN="$RCA_HOME/bin"
RCA_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/rca"
RCA_RICING="Rebecca-Capri-Akira"
mkdir -p "$RCA_STATE"

# Dernière valeur d'une clé de settings.conf (ou défaut).
rca_setting() {
  local key="$1" default="${2:-}" value
  value="$(sed -n "s/^[[:space:]]*$key[[:space:]]*=[[:space:]]*//p" "$RCA_HOME/settings.conf" 2>/dev/null | tail -n1)"
  value="${value/#\~/$HOME}"
  printf '%s' "${value:-$default}"
}

# Toutes les valeurs d'une clé répétée.
rca_settings() {
  sed -n "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*//p" "$RCA_HOME/settings.conf" 2>/dev/null
}

# Vrai quand ce ricing est actif (ses fichiers sont ceux de ~/.config).
rca_active() {
  [[ "$(cat "$HOME/.hypr-switch/.current_shell" 2>/dev/null)" == "$RCA_RICING" ]] && return 0
  # Sans hypr-switch (après la migration), le ricing est la config elle-même.
  [[ ! -d "$HOME/.hypr-switch" ]]
}

# Vrai quand ~/.config/<item> appartient à ce ricing.
rca_owns() {
  local real
  real="$(readlink -f "$HOME/.config/$1" 2>/dev/null)" || return 1
  [[ "$real" == *"/shells/$RCA_RICING/"* || ! -d "$HOME/.hypr-switch" ]]
}

rca_qs() {
  qs -c rca ipc call "$@" >/dev/null 2>&1
}

rca_notify() {
  notify-send -a "Rebecca" "$@" 2>/dev/null || true
}

rca_launch() {
  if command -v uwsm-app >/dev/null 2>&1; then
    setsid uwsm-app -- "$@" >/dev/null 2>&1 &
  else
    setsid "$@" >/dev/null 2>&1 &
  fi
}
