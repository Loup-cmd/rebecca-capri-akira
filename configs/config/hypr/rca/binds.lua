-- Raccourcis : mêmes combinaisons qu'Omarchy, réimplémentées sans lui.
-- Les descriptions sont lues par l'aide (SUPER + K) via `hyprctl binds -j`.
-- Rangée des chiffres en codes physiques (code:10 à code:19), donc AZERTY OK.

local bind, ipc, script, launch = rca.bind, rca.ipc, rca.script, rca.launch

---------------------------------------------------------------- Applications
local function terminal()
  local window = hl.get_active_window()
  if window and window.pid then
    hl.exec_cmd(script("rca-term", "--pid=" .. window.pid))
  else
    hl.exec_cmd(script("rca-term"))
  end
end

bind("SUPER + RETURN", "Terminal", terminal)
bind("SUPER + SHIFT + RETURN", "Navigateur", script("rca-browser"))
bind("SUPER + SHIFT + B", "Navigateur", script("rca-browser"))
bind("SUPER + SHIFT + ALT + B", "Navigateur (privé)", script("rca-browser", "--private"))
bind("SUPER + SHIFT + F", "Gestionnaire de fichiers", launch("nautilus --new-window"))
bind("SUPER + SHIFT + ALT + F", "Gestionnaire de fichiers (cwd)", script("rca-term", "--files"))
bind("SUPER + SHIFT + N", "Éditeur", script("rca-term", "--editor"))
bind("SUPER + ALT + RETURN", "Tmux", script("rca-term", "-- tmux new -A -s Work"))
bind("SUPER + CTRL + RETURN", "Herdr", script("rca-term", "-- herdr"))
bind("SUPER + SHIFT + Q", "Calculatrice", rca.has("omacalc") and launch("omacalc") or ipc("launcher", "open", "calc"))
bind("XF86Calculator", "Calculatrice", rca.has("omacalc") and launch("omacalc") or ipc("launcher", "open", "calc"))
bind("SUPER + SHIFT + M", "Musique", script("rca-focus", "'^[Ss]potify$' spotify"))
bind("SUPER + SHIFT + ALT + M", "Musique (TUI)", script("rca-tui", "cliamp cliamp"))
bind("SUPER + SHIFT + D", "Discord", launch("discord"))
bind("SUPER + SHIFT + G", "Signal", script("rca-focus", "'^signal$' signal-desktop"))
bind("SUPER + SHIFT + O", "Obsidian", script("rca-focus", "'^obsidian$' obsidian"))
bind("SUPER + SHIFT + W", "Omawrite", launch("omawrite"))
bind("SUPER + SHIFT + T", "Activité (btop)", script("rca-tui", "btop btop"))
bind("SUPER + SHIFT + CTRL + A", "Agent (opencode)", script("rca-term", "-- opencode"))

-- Web apps.
local function webapp(keys, name, url, focus)
  bind(keys, name, script("rca-webapp", rca.quote(url) .. (focus and (" --focus " .. rca.quote(name)) or "")))
end
webapp("SUPER + SHIFT + A", "ChatGPT", "https://chatgpt.com")
webapp("SUPER + SHIFT + ALT + A", "Grok", "https://grok.com")
webapp("SUPER + SHIFT + C", "Calendrier", "https://app.hey.com/calendar/weeks/")
webapp("SUPER + SHIFT + E", "Email", "https://app.hey.com")
webapp("SUPER + SHIFT + ALT + E", "Nouvel email", "https://app.hey.com/messages/new?display=standalone&new_window=true")
webapp("SUPER + SHIFT + Y", "YouTube", "https://youtube.com/")
webapp("SUPER + SHIFT + ALT + G", "WhatsApp", "https://web.whatsapp.com/", true)
webapp("SUPER + SHIFT + CTRL + G", "Google Messages", "https://messages.google.com/web/conversations", true)
webapp("SUPER + SHIFT + P", "Google Photos", "https://photos.google.com/", true)
webapp("SUPER + SHIFT + S", "Google Maps", "https://maps.google.com/", true)
webapp("SUPER + SHIFT + X", "X", "https://x.com/")
webapp("SUPER + SHIFT + ALT + X", "Publier sur X", "https://x.com/compose/post")

---------------------------------------------------------------- Fenêtres
bind("SUPER + W", "Fermer la fenêtre", hl.dsp.window.close())
bind("SUPER + Q", "Fermer la fenêtre", hl.dsp.window.close())
bind("CTRL + ALT + DELETE", "Fermer toutes les fenêtres", script("rca-hypr", "close-all"))
bind("SUPER + J", "Basculer la division", hl.dsp.layout("togglesplit"))
bind("SUPER + P", "Pseudo-tuile", hl.dsp.window.pseudo())
bind("SUPER + T", "Flottante / mosaïque", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + F", "Plein écran", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
bind("SUPER + CTRL + F", "Plein écran en mosaïque", script("rca-hypr", "tiled-fullscreen"))
bind("SUPER + ALT + F", "Pleine largeur", hl.dsp.window.fullscreen({ mode = "maximized" }))
bind("SUPER + O", "Détacher la fenêtre (flottante, épinglée)", script("rca-hypr", "pop"))
bind("SUPER + ALT + Home", "Enregistrer la largeur", script("rca-hypr", "width save"))
bind("SUPER + Home", "Restaurer la largeur", script("rca-hypr", "width restore"))
bind("SUPER + L", "Disposition suivante", script("rca-hypr", "layout next"))
bind("SUPER + ALT + L", "Disposition précédente", script("rca-hypr", "layout prev"))
bind("SUPER + BACKSPACE", "Transparence de la fenêtre", script("rca-hypr", "transparency"))
bind("SUPER + SHIFT + BACKSPACE", "Marges des fenêtres", script("rca-hypr", "gaps"))
bind("SUPER + CTRL + BACKSPACE", "Aspect carré (fenêtre seule)", script("rca-hypr", "square"))
bind("SUPER + CTRL + ALT + F", "Bureau plein écran (sans pupitre ni marges)", script("rca-hypr", "zen"))

bind("SUPER + LEFT", "Fenêtre de gauche", hl.dsp.focus({ direction = "l" }))
bind("SUPER + RIGHT", "Fenêtre de droite", hl.dsp.focus({ direction = "r" }))
bind("SUPER + UP", "Fenêtre du dessus", hl.dsp.focus({ direction = "u" }))
bind("SUPER + DOWN", "Fenêtre du dessous", hl.dsp.focus({ direction = "d" }))
bind("SUPER + SHIFT + LEFT", "Échanger à gauche", hl.dsp.window.swap({ direction = "l" }))
bind("SUPER + SHIFT + RIGHT", "Échanger à droite", hl.dsp.window.swap({ direction = "r" }))
bind("SUPER + SHIFT + UP", "Échanger en haut", hl.dsp.window.swap({ direction = "u" }))
bind("SUPER + SHIFT + DOWN", "Échanger en bas", hl.dsp.window.swap({ direction = "d" }))

bind("ALT + TAB", "Fenêtre suivante", hl.dsp.window.cycle_next())
bind("ALT + TAB", nil, hl.dsp.window.bring_to_top())
bind("ALT + SHIFT + TAB", "Fenêtre précédente", hl.dsp.window.cycle_next({ next = false }))
bind("ALT + SHIFT + TAB", nil, hl.dsp.window.alter_zorder({ mode = "bottom" }))
bind("CTRL + ALT + TAB", "Écran suivant", hl.dsp.focus({ monitor = "+1" }))
bind("CTRL + ALT + SHIFT + TAB", "Écran précédent", hl.dsp.focus({ monitor = "-1" }))

-- Redimensionnement : touches ) et = en AZERTY (code:20 et code:21).
local function resize(keys, description, x, y)
  bind(keys, description, hl.dsp.window.resize({ x = x, y = y, relative = true }), { repeating = true })
end
resize("SUPER + code:20", "Élargir vers la gauche", -100, 0)
resize("SUPER + code:21", "Réduire vers la gauche", 100, 0)
resize("SUPER + SHIFT + code:20", "Réduire vers le haut", 0, -100)
resize("SUPER + SHIFT + code:21", "Agrandir vers le bas", 0, 100)
resize("SUPER + ALT + code:20", "Élargir un peu", -25, 0)
resize("SUPER + ALT + code:21", "Réduire un peu", 25, 0)
resize("SUPER + SHIFT + ALT + code:20", "Réduire un peu vers le haut", 0, -25)
resize("SUPER + SHIFT + ALT + code:21", "Agrandir un peu vers le bas", 0, 25)
resize("SUPER + CTRL + code:20", "Élargir beaucoup", -300, 0)
resize("SUPER + CTRL + code:21", "Réduire beaucoup", 300, 0)
resize("SUPER + CTRL + SHIFT + code:20", "Réduire beaucoup vers le haut", 0, -300)
resize("SUPER + CTRL + SHIFT + code:21", "Agrandir beaucoup vers le bas", 0, 300)

bind("SUPER + mouse:272", "Déplacer la fenêtre", hl.dsp.window.drag(), { mouse = true })
bind("SUPER + mouse:273", "Redimensionner la fenêtre", hl.dsp.window.resize(), { mouse = true })

-- Groupes.
bind("SUPER + G", "Grouper / dégrouper", hl.dsp.group.toggle())
bind("SUPER + ALT + G", "Sortir du groupe", hl.dsp.window.move({ out_of_group = true }))
bind("SUPER + ALT + LEFT", "Vers le groupe de gauche", hl.dsp.window.move({ into_group = "l" }))
bind("SUPER + ALT + RIGHT", "Vers le groupe de droite", hl.dsp.window.move({ into_group = "r" }))
bind("SUPER + ALT + UP", "Vers le groupe du haut", hl.dsp.window.move({ into_group = "u" }))
bind("SUPER + ALT + DOWN", "Vers le groupe du bas", hl.dsp.window.move({ into_group = "d" }))
bind("SUPER + ALT + TAB", "Fenêtre suivante du groupe", hl.dsp.group.next())
bind("SUPER + ALT + SHIFT + TAB", "Fenêtre précédente du groupe", hl.dsp.group.prev())
bind("SUPER + CTRL + LEFT", "Groupe : focus à gauche", hl.dsp.group.prev())
bind("SUPER + CTRL + RIGHT", "Groupe : focus à droite", hl.dsp.group.next())
bind("SUPER + ALT + mouse_down", "Fenêtre suivante du groupe", hl.dsp.group.next())
bind("SUPER + ALT + mouse_up", "Fenêtre précédente du groupe", hl.dsp.group.prev())
for index = 1, 5 do
  bind("SUPER + ALT + code:" .. (index + 9), "Fenêtre " .. index .. " du groupe", hl.dsp.group.active({ index = index }))
end

---------------------------------------------------------------- Espaces de travail
for ws = 1, 10 do
  local key = "code:" .. (ws + 9)
  bind("SUPER + " .. key, "Espace " .. ws, hl.dsp.focus({ workspace = ws }))
  bind("SUPER + SHIFT + " .. key, "Fenêtre vers l'espace " .. ws, hl.dsp.window.move({ workspace = ws }))
  bind("SUPER + SHIFT + ALT + " .. key, "Fenêtre vers l'espace " .. ws .. " sans suivre", hl.dsp.window.move({ workspace = ws, follow = false }))
end
bind("SUPER + TAB", "Espace suivant", hl.dsp.focus({ workspace = "m+1" }))
bind("SUPER + SHIFT + TAB", "Espace précédent", hl.dsp.focus({ workspace = "m-1" }))
bind("SUPER + CTRL + TAB", "Espace d'avant", hl.dsp.focus({ workspace = "previous_per_monitor" }))
bind("SUPER + mouse_down", "Espace suivant", hl.dsp.focus({ workspace = "m+1" }))
bind("SUPER + mouse_up", "Espace précédent", hl.dsp.focus({ workspace = "m-1" }))

bind("SUPER + S", "Scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
bind("SUPER + ALT + S", "Fenêtre vers le scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
-- Touche ² (code:49) en AZERTY, ` en QWERTY.
bind("SUPER + code:49", "Console Quake", hl.dsp.workspace.toggle_special("qconsole"))
bind("SUPER + SHIFT + code:49", "Fenêtre vers la console Quake", hl.dsp.window.move({ workspace = "special:qconsole", follow = false }))

---------------------------------------------------------------- Shell
bind("SUPER + SPACE", "Menu", ipc("menu", "open", "root"))
bind("SUPER + ALT + SPACE", "Applications", ipc("launcher", "open", "apps"))
bind("SUPER + ESCAPE", "Menu système", ipc("menu", "open", "system"))
bind("XF86PowerOff", "Menu système", ipc("menu", "open", "system"), { locked = true })
bind("SUPER + K", "Raccourcis clavier", ipc("panel", "toggle", "keybinds"))
bind("SUPER + SHIFT + SPACE", "Afficher / masquer le pupitre", ipc("bar", "pin"))
bind("SUPER + CTRL + SPACE", "Fonds d'écran", ipc("panel", "toggle", "wallpapers"))
bind("SUPER + CTRL + W", "Fonds d'écran", ipc("panel", "toggle", "wallpapers"))
bind("SUPER + CTRL + T", "Thème jour / nuit", ipc("menu", "open", "theme"))
bind("SUPER + SHIFT + CTRL + SPACE", "Thème jour / nuit", ipc("menu", "open", "theme"))
bind("SUPER + CTRL + E", "Émojis", ipc("launcher", "open", "emoji"))
bind("SUPER + CTRL + C", "Menu de capture", ipc("menu", "open", "capture"))
bind("SUPER + CTRL + O", "Menu des bascules", ipc("menu", "open", "toggle"))
bind("SUPER + CTRL + H", "Menu matériel", ipc("menu", "open", "hardware"))
bind("SUPER + CTRL + S", "Partager", ipc("menu", "open", "share"))

-- Panneaux.
bind("SUPER + CTRL + A", "Audio", ipc("panel", "toggle", "audio"))
bind("SUPER + CTRL + B", "Bluetooth", ipc("panel", "toggle", "bluetooth"))
bind("SUPER + CTRL + N", "Réseau", ipc("panel", "toggle", "network"))
bind("SUPER + CTRL + D", "Affichage", ipc("panel", "toggle", "display"))
bind("SUPER + CTRL + P", "Alimentation", ipc("panel", "toggle", "power"))
bind("SUPER + CTRL + ALT + D", "Calendrier", ipc("panel", "toggle", "calendar"))
bind("SUPER + CTRL + ALT + E", "Horloge mondiale", ipc("panel", "toggle", "worldclock"))
bind("SUPER + CTRL + ALT + W", "Météo", ipc("panel", "toggle", "weather"))
bind("SUPER + CTRL + ALT + T", "Afficher l'heure", ipc("osd", "time"))
bind("SUPER + CTRL + ALT + B", "Batterie restante", ipc("osd", "battery"))
-- Panneaux numérotés (les « panneaux de la barre » d'Omarchy).
local bar_panels = { "utils", "control", "notifications", "audio", "network", "bluetooth", "monitor", "weather", "calendar" }
for i, name in ipairs(bar_panels) do
  bind("SUPER + CTRL + code:" .. (i + 9), "Panneau " .. i .. " (" .. name .. ")", ipc("panel", "toggle", name))
end

-- Rappels.
bind("SUPER + CTRL + R", "Programmer un rappel", ipc("launcher", "open", "reminder"))
bind("SUPER + CTRL + ALT + R", "Afficher les rappels", ipc("panel", "toggle", "reminders"))
bind("SUPER + SHIFT + CTRL + R", "Effacer les rappels", script("rca-reminder", "clear"))

-- Notifications.
bind("SUPER + comma", "Notification : agir / ignorer", ipc("notifs", "act"))
bind("SUPER + SHIFT + comma", "Ignorer toutes les notifications", ipc("notifs", "dismissAll"))
bind("SUPER + CTRL + comma", "Notifications au clavier", ipc("notifs", "keyboard"))
bind("SUPER + ALT + comma", "Ignorer la dernière notification", ipc("notifs", "dismissOne"))
bind("SUPER + SHIFT + ALT + comma", "Historique des notifications", ipc("panel", "toggle", "notifications"))
bind("SUPER + CTRL + ALT + comma", "Silence des notifications", ipc("notifs", "silence"))

---------------------------------------------------------------- Presse-papiers
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

local function is_terminal()
  local window = hl.get_active_window()
  if not window then return false end
  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then return true end
  end
  return false
end

local function universal(mods, key, term_mods, term_key)
  return function()
    if is_terminal() then
      send_shortcut_once(term_mods, term_key)()
    else
      send_shortcut_once(mods, key)()
    end
  end
end

bind("SUPER + A", "Tout sélectionner", send_shortcut_once("CTRL", "A"))
bind("SUPER + C", "Copie universelle", universal("CTRL", "C", "CTRL SHIFT", "C"))
bind("SUPER + V", "Collage universel", universal("CTRL", "V", "CTRL SHIFT", "V"))
bind("SUPER + X", "Couper universel", send_shortcut_once("CTRL", "X"))
bind("SUPER + CTRL + V", "Presse-papiers", ipc("launcher", "open", "clipboard"))

---------------------------------------------------------------- Captures
bind("Print", "Capture d'écran", script("rca-capture", "shot region"))
bind("SUPER + CTRL + ALT + C", "Capture d'écran", script("rca-capture", "shot region"))
bind("ALT + Print", "Enregistrement d'écran", script("rca-capture", "record toggle"))
bind("SUPER + Print", "Pipette à couleur", script("rca-capture", "color"))
bind("SUPER + CTRL + Print", "Extraire le texte (OCR)", script("rca-capture", "ocr"))

---------------------------------------------------------------- Système
bind("SUPER + CTRL + L", "Verrouiller", ipc("lock", "lock"))
bind("SUPER + CTRL + I", "Verrouillage auto on/off", script("rca-idle", "toggle"))
bind("SUPER + slash", "Échelle de l'écran +", script("rca-hypr", "scale up"))
bind("SUPER + ALT + slash", "Échelle de l'écran −", script("rca-hypr", "scale down"))
bind("SUPER + CTRL + Delete", "Écran du portable on/off", script("rca-hypr", "internal toggle"))

bind("SUPER + CTRL + Z", "Zoom +", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)
bind("SUPER + CTRL + ALT + Z", "Zoom réinitialisé", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(ipc("lock", "lock")), { locked = true })

---------------------------------------------------------------- Média
local function media(keys, description, action, repeating)
  bind(keys, description, action, { locked = true, repeating = repeating or false })
end
media("XF86AudioRaiseVolume", "Volume +", script("rca-audio", "up"), true)
media("XF86AudioLowerVolume", "Volume −", script("rca-audio", "down"), true)
media("ALT + XF86AudioRaiseVolume", "Volume + précis", script("rca-audio", "up 1"), true)
media("ALT + XF86AudioLowerVolume", "Volume − précis", script("rca-audio", "down 1"), true)
media("XF86AudioMute", "Muet", script("rca-audio", "mute"))
media("XF86AudioMicMute", "Micro muet", script("rca-audio", "mic-mute"))
media("SHIFT + XF86AudioMute", "Changer de sortie audio", script("rca-audio", "next-output"))
media("XF86MonBrightnessUp", "Luminosité +", script("rca-bright", "up"), true)
media("XF86MonBrightnessDown", "Luminosité −", script("rca-bright", "down"), true)
media("ALT + XF86MonBrightnessUp", "Luminosité + précise", script("rca-bright", "up 1"), true)
media("ALT + XF86MonBrightnessDown", "Luminosité − précise", script("rca-bright", "down 1"), true)
media("SHIFT + XF86MonBrightnessUp", "Luminosité max", script("rca-bright", "set 100"))
media("SHIFT + XF86MonBrightnessDown", "Luminosité min", script("rca-bright", "set 1"))
media("XF86KbdBrightnessUp", "Clavier +", script("rca-bright", "kbd up"), true)
media("XF86KbdBrightnessDown", "Clavier −", script("rca-bright", "kbd down"), true)
media("XF86KbdLightOnOff", "Rétroéclairage clavier", script("rca-bright", "kbd cycle"))
media("XF86AudioNext", "Piste suivante", "playerctl next")
media("ALT + XF86AudioPlay", "Piste suivante", "playerctl next")
media("XF86AudioPrev", "Piste précédente", "playerctl previous")
media("ALT + SHIFT + XF86AudioPlay", "Piste précédente", "playerctl previous")
media("XF86AudioPlay", "Lecture / pause", "playerctl play-pause")
media("XF86AudioPause", "Lecture / pause", "playerctl play-pause")
media("XF86Eject", "Éjecter", "eject")

---------------------------------------------------------------- Dictée
if rca.has("superwhisper") then
  bind("ALT + SPACE", "Dictée on/off", "superwhisper record")
  rca.bind_hold("ALT + Alt_R", "Dictée (maintenir)", "superwhisper start; " .. ipc("status", "voice", "true"),
    ipc("status", "voice", "false") .. "; systemctl --user is-active --quiet superwhisper.service && superwhisper stop", { ignore_mods = true })
end

-- Assistant vocal local (Needle 3 + Whisper) : maintenir la touche OMEN.
local voice = rca.home .. "/.local/bin/needle-voice"
if rca.file_exists(voice) then
  rca.bind_hold("XF86Launch2", "Assistant vocal (maintenir OMEN)", voice .. " start; " .. ipc("status", "voice", "true"),
    voice .. " stop; " .. ipc("status", "voice", "false"),
    { ignore_mods = true, non_consuming = true })
end
