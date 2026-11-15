-- Rebecca-Capri-Akira — Hyprland autonome (aucune dépendance à /usr/share/omarchy).
--
-- Ordre : environnement, machine, apparence, règles, raccourcis, démarrage.
-- Les couleurs viennent de ~/.local/state/rca/theme/hyprland.lua, réécrit par
-- `rca-theme` à chaque bascule jour/nuit.

local home = os.getenv("HOME") or ""
local dir = (debug.getinfo(1, "S").source:match("^@(.*/)")) or (home .. "/.config/hypr/")
package.path = dir .. "?.lua;" .. package.path

rca = {
  home = home,
  bin = home .. "/.config/rca/bin",
  state = home .. "/.local/state/rca",
}

require("rca.util")
require("rca.env")
require("rca.machine")
require("rca.look")
require("rca.rules")
require("rca.binds")
require("rca.autostart")

-- Raccourcis gérés par Superwhisper (il réécrit lui-même ce fichier).
rca.dofile_if_exists(home .. "/.config/superwhisper/shortcuts.lua")

-- Réglages personnels non versionnés, chargés en dernier.
rca.dofile_if_exists(home .. "/.config/rca/user.lua")

-- Les deux marqueurs ci-dessous empêchent ricing-switch d'ajouter la keymap
-- Omarchy et l'overlay machine : ce ricing porte les siens (rca/binds.lua,
-- rca/machine.lua) et doit continuer à marcher une fois Omarchy désinstallé.
-- hypr-switch: Omarchy keymap overlay (generated; do not edit)
-- hypr-switch: machine overlay (monitors + keyboard of this machine; do not edit)
