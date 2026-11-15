-- Règles de fenêtres et de calques.

rca.window(".*", { suppress_event = "maximize" })

-- Glisser-déposer XWayland.
rca.window({ class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false }, { no_focus = true })

-- Terminaux : étiquette commune (copier/coller universel, transparence).
rca.window("(Alacritty|kitty|com.mitchellh.ghostty|foot|org\\.codeberg\\.dnkl\\.foot|wezterm|rca\\..*)", { tag = "+terminal" })
rca.window({ tag = "terminal" }, { opacity = "0.985 0.96" })
rca.window({ tag = "transparent" }, { opacity = "0.94 0.88" })

-- Fenêtres flottantes standard.
rca.window("(rca\\.(float|btop|cliamp|impala|wiremix)|org.gnome.NautilusPreviewer|org.gnome.Evince|imv|mpv|omacalc|pavucontrol|blueberry.py|nm-connection-editor|xdg-desktop-portal-gtk|org.gnome.Calculator)", { tag = "+floating-window" })
rca.window({ class = "(sublime_text|DesktopEditors|org.gnome.Nautilus)", title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)" }, { tag = "+floating-window" })
rca.window({ tag = "floating-window" }, { float = true, center = true, size = { 875, 600 } })

-- Fenêtre détachée (SUPER + O) : flottante, épinglée, coins plus francs.
rca.window({ tag = "pop" }, { rounding = 14 })

-- Navigateurs.
rca.window("((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)", { tag = "+chromium-based-browser" })
rca.window("([fF]irefox|zen|librewolf)", { tag = "+firefox-based-browser" })
rca.window({ tag = "chromium-based-browser" }, { tile = true })
rca.window("(^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$)", { tag = "-chromium-based-browser" })
rca.window({ title = ".*is sharing.*" }, { workspace = "special silent" })

-- Image dans l'image : coin haut droit, épinglée, sans bordure.
rca.window({ title = "(Picture.?in.?[Pp]icture)" }, { tag = "+pip" })
rca.window({ tag = "pip" }, {
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  move = { "(monitor_w-window_w-24)", "(monitor_h*0.04)" },
})

-- Empêche la mise en veille pendant une vidéo plein écran.
rca.window(".*", { idle_inhibit = "fullscreen" })

-- Tes réglages personnels (repris de default).
rca.window({ class = "^steam$", title = "^Steam$" }, { tile = true })
rca.window({ class = "(org\\.localsend\\.)?localsend(_app)?" }, { tile = true })
rca.window({ class = "(org\\.localsend\\.)?localsend(_app)?", title = "^Share$" }, { float = true, center = true })
rca.window({ class = "^[bB]itwarden$" }, { tile = true })
rca.window({ class = "^steam_app_battlenet$", title = "^Battle\\.net$" }, { tile = true })
rca.window({ class = ".*[Rr]esolve.*", title = "^DaVinci Resolve( Studio)? - .+$" }, { tile = true, fullscreen = false })
rca.window({ class = ".*[Rr]esolve.*", title = "^(Preferences|Find Directory|Dialog|Project Manager)$" }, { float = true })

-- Calques du shell : le QML anime lui-même ses panneaux, le compositeur
-- n'ajoute rien par-dessus.
hl.layer_rule({ match = { namespace = "^rca-" }, no_anim = true, animation = "none" })
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true, animation = "none" })

-- Console Quake (SUPER + ²) : demi-écran qui tombe du haut, avec un kitty
-- ouvert à la première ouverture seulement.
local CONSOLE = "special:qconsole"
hl.workspace_rule({
  workspace = CONSOLE,
  gaps_in = 0,
  gaps_out = { top = 0, right = 160, bottom = 420, left = 160 },
  no_border = true,
})
hl.on("workspace.created", function(ws)
  if ws and ws.name == CONSOLE and ws.is_empty then
    hl.exec_cmd("kitty --class rca.console", { workspace = CONSOLE .. " silent" })
  end
end)

-- Compaction des espaces de travail (ta règle de default) : quand on quitte un
-- espace vide, les espaces occupés remontent pour combler les trous.
require("rca.compaction")
